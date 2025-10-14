#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Variables
source_dir="/var/lib/docker"
new_mount_dir="/data"
partition="/dev/sdb1"

# Stop Docker service
echo "Stopping Docker service..."
systemctl stop docker

# Create new mount directory if it doesn't exist
if [ ! -d "$new_mount_dir" ]; then
  echo "Creating new mount directory at $new_mount_dir..."
  mkdir -p "$new_mount_dir"
fi

# Mount the partition if not already mounted
if ! findmnt -rn $partition $new_mount_dir > /dev/null; then
  echo "Mounting $partition to $new_mount_dir..."
  mount $partition $new_mount_dir
  # Add entry to /etc/fstab for automatic remounting on boot
  echo "Adding mount to /etc/fstab..."
  UUID=$(blkid -s UUID -o value $partition)
  echo "UUID=$UUID $new_mount_dir ext4 defaults 0 2" >> /etc/fstab
fi

# Copy Docker data to new partition
echo "Copying Docker data to $new_mount_dir..."
rsync -av $source_dir/ $new_mount_dir/

# Rename old Docker directory
echo "Renaming old Docker directory..."
mv $source_dir $source_dir.bak

# Restart Docker service
echo "Restarting Docker service..."
systemctl start docker

# Verify Docker info
echo "Verifying Docker is correctly configured..."
docker info | grep "Docker Root Dir"

echo "Script completed successfully. If everything is correct, you may remove the backup with:"
echo "rm -rf $source_dir.bak"