#!/usr/bin/env bash
# CloudLAMP NFS server configuration script
# Copyright 2018 Google, LLC
# Sebastian Weigand <tdg@google.com>

# Print commands as executed:
set -x

# The disk ID is set by Google when the device is attached:
#ID="google-${nfs_disk_name}"
ID="google-disky"
LABEL="CloudLAMP-NFS"
STATEFILE="/etc/cloudlamp-configured.state"

# If we've already run this script before, just exit:
if [ -f $STATEFILE ]; then
    exit
fi

# Idempotently install requisite packages:
# TODO: Implement wait for apt/dpkg here via process grep:

apt-get update
apt-get install -y nfs-kernel-server

# We don't need partitions for FS creation or resizing:
mkfs.ext4 -L $LABEL /dev/disk/by-id/$ID

# Our local NFS directory:
mkdir -p /srv/nfs

# /dev/disk/by-label takes a second or two to update, so use ID here:
mount /dev/disk/by-id/$ID /srv/nfs

# Write persistence information for file systems:
echo "LABEL=$LABEL /srv/nfs ext4 defaults 1 2" >> /etc/fstab
echo "/srv/nfs *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports

# Export the shares, and print them:
exportfs -a
showmount -e

# Mark this script as having run successfully:
touch $STATEFILE