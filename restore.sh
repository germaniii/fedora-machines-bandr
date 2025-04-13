#!/bin/bash

# Usage: ./restore_vm.sh <vm_name> <backup_directory> [<image_directory>]
# Example: ./restore_vm.sh myvm /backups/myvm /var/lib/libvirt/images

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (use sudo)."
    exit 1
fi

VM_NAME="${1%/}"
BACKUP_DIR="$2" #$2
IMAGE_DIR="${3:-/var/lib/libvirt/images}"
TIMESTAMP=$(basename "$BACKUP_DIR" | sed 's/^.*_//')
RESTORE_PATH="${IMAGE_DIR}/${VM_NAME}_${TIMESTAMP}"

# Ensure the backup directory exists
if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Error: Backup directory '$BACKUP_DIR' does not exist."
    exit 1
fi

# Ensure the image directory exists
if [[ ! -d "$IMAGE_DIR" ]]; then
    echo "Error: Image directory '$IMAGE_DIR' does not exist."
    exit 1
fi

# Step 1: Check if the VM is running and stop it if necessary
if virsh domstate "$VM_NAME" | grep -q 'running'; then
    echo "VM '$VM_NAME' is running. Attempting to shut it down gracefully..."
    virsh shutdown "$VM_NAME" || {
        echo "Graceful shutdown failed. Forcing shutdown..."
        virsh destroy "$VM_NAME"
    }
    # Wait until the VM is completely shut down
    while virsh domstate "$VM_NAME" | grep -q 'running'; do
        echo "Waiting for VM '$VM_NAME' to shut down..."
        sleep 2
    done
    echo "VM '$VM_NAME' has been stopped."
else
    echo "VM '$VM_NAME' is not running."
fi

# Step 2: Restore the VM configuration
echo "Restoring VM configuration..."
if [[ -f "${BACKUP_DIR}/${VM_NAME}.xml" ]]; then
    cp "${BACKUP_DIR}/${VM_NAME}.xml" "${IMAGE_DIR}/${VM_NAME}.xml"
else
    echo "Error: Configuration file '${VM_NAME}.xml' not found in backup."
    exit 1
fi

# Step 3: Restore the disk image(s)
echo "Restoring disk image(s)..."
mapfile -t DISKS < <(virsh dumpxml "$VM_NAME" | grep -oPm1 "(?<=<source file=')[^']+")

for DISK in "${DISKS[@]}"; do
    DISK_BASENAME=$(basename "$DISK")
    BACKUP_DISK="${BACKUP_DIR}/${DISK_BASENAME}"
    if [[ -f "$BACKUP_DISK" ]]; then
        cp --sparse=always "$BACKUP_DISK" "${IMAGE_DIR}/${DISK_BASENAME}"
        chown qemu:qemu "${IMAGE_DIR}/${DISK_BASENAME}"
        chmod 0640 "${IMAGE_DIR}/${DISK_BASENAME}"
    else
        echo "Warning: Disk file '$BACKUP_DISK' not found in backup. Skipping."
    fi
done

# Step 4: Define the VM
echo "Defining the VM..."
virsh define "${IMAGE_DIR}/${VM_NAME}.xml"

# Step 5: Start the VM
echo "Starting VM..."
virsh start "$VM_NAME"

echo "VM '$VM_NAME' restored and started successfully."
