#!/bin/bash
sudo mkdir /opt/cryptpad
disk=$(lsblk -r | tail -n 1 | cut -d " " -f 1)
echo "Partitioning $disk"
sudo sgdisk -n -N -t 8300 /dev/$disk
sudo mkfs.ext4 /dev/${disk}1
echo "/dev/${disk}1 /opt/cryptpad ext4 defaults 0 1" | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo mount -a
