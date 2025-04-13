# Fedora Backup Scripts

In this repo are backup and restore scripts for Fedora server virtual machines

## BACKUP

Just run the following command to create a backup

```bash
sudo ./backup <vm-name>
# sudo ./backup vmos-deployment
```

Optionally, you can also set a backup directory, but I prefer having it easy by setting the name as the directory

```bash
sudo ./backup <vm-name> <backup-dir>
# sudo ./backup vmos-deployment deployment/main
```

## RESTORE

Just run the following command to restore a backup

```
sudo ./restore <vm-name> <backup-dir>
# sudo ./restore vmos-deployment vmos-deployment/vmos-deployment-20250401_12231451
```

Optionally, you can also set a target output directory, but by default, Fedora stores images in `/var/lib/libvirt/images`

```
sudo ./restore <vm-name> <backup-dir> <target-dir>
# sudo ./restore vmos-deployment vmos-deployment/vmos-deployment-20250401_12231451 /var/lib/libvirt/images-2
```

## SEND TO NAS

Just run the following command to send to nas

```
sudo ./send_to_nas <backup-dir> <nas-target>
# sudo ./send_to_nas vmos-deployment/vmos-deployment-20250401_12231451 username@nas_ip:/path/to/pool/backups/folder
```

## RECEIVE FROM NAS

Just run the following command to receive from nas

```
sudo ./receive_from_nas <vm-name> <backup-dir>
# sudo ./receive_from_nas vmos-deployment vmos-deployment/vmos-deployment-20250401_12231451
```
