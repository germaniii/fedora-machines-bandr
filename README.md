# Fedora Backup Scripts

In this repo are backup and restore scripts for Fedora server

## BACKUP

Just run the following command to create a backup

```bash
sudo ./backup.sh <vm-name>
# sudo ./backup.sh vmos-deployment
```

Optionally, you can also set a backup directory, but I prefer having it easy by setting the name as the directory

```bash
sudo ./backup.sh <vm-name> <backup-dir>
# sudo ./backup.sh vmos-deployment deployment/main
```

## RESTORE

Just run the following command to restore a backup

```
sudo ./restore.sh <vm-name> <backup-dir>
# sudo ./restore.sh vmos-deployment vmos-deployment/vmos-deployment-20250401_12231451
```

Optionally, you can also set a target output directory, but by default, Fedora stores images in `/var/lib/libvirt/images`

```
sudo ./restore.sh <vm-name> <backup-dir> <target-dir>
# sudo ./restore.sh vmos-deployment vmos-deployment/vmos-deployment-20250401_12231451 /var/lib/libvirt/images-2
```
