#!/usr/bin/env bash
# CloudLAMP NFS server configuration script
# Copyright 2018 Google, LLC
# Sebastian Weigand <tdg@google.com>

# The disk ID is set by Google when the device is attached:
ID="google-cloudlamp-nfs"
LABEL="CloudLAMP-NFS"

# If we've already run this script before, just exit:
if [ -b /dev/disk/by-label/$LABEL ]; then
    exit
fi

apt-get update && apt-get -y upgrade
apt-get install -y nfs-kernel-server

# We don't need partitions for FS creation or resizing:
mkfs.ext4 -L $LABEL /dev/disk/by-id/$ID

mkdir -p /srv/nfs

# /dev/disk/by-label takes a second or two to update, so use ID here:
mount /dev/disk/by-id/$ID /srv/nfs

echo "LABEL=$LABEL /srv/nfs ext4 defaults 1 2" >> /etc/fstab
echo "/srv/nfs *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports

exportfs -a
showmount -e