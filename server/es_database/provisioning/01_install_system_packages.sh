#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e  # Make sure errors will stop execution

# Create Filesystem and mount EBS:
lsblk
read -p "Please provide data volume NAME from above list: "
mkfs -t xfs /dev/$REPLY
mkdir /data
mount /dev/$REPLY /data

# Make it persistent by adding to FSTAB
ebs_uuid=$(blkid -s UUID -o value /dev/$REPLY)
echo "UUID=$ebs_uuid  /data  xfs  defaults,nofail  0  2" >> /etc/fstab

# Do initial update/upgrade
apt update
apt upgrade -y

# Install basic compilers
../../../common/scripts/install_compilers.sh

# Install git
../../../common/scripts/install_git.sh

# Install jre
../../../common/scripts/install_jre.sh

# Install ES
../../../common/scripts/install_es.sh

# Run autoremove just in case
apt autoremove -y
