#!/bin/bash

echo "Enter the device partition name like xvdbd, xvdbe"
read PARTITION_NANE 

# Define variables
DEVICE_NAME="/dev/$PARTITION_NANE"  # Device name on the instance (adjust if needed)
MOUNT_POINT="/mnt/$PARTITION_NANE"  # Mount point directory on the instance

# Check if the device is available and then proceed
echo "Checking if the device is available..."
if lsblk | grep -q "$PARTITION_NANE"; then
  echo "Device $DEVICE_NAME is available. Proceeding with formatting and mounting..."

  # Create a filesystem on the volume (skip this if the volume is not new)
  echo "Creating filesystem on $DEVICE_NAME..."
  sudo mkfs -t ext4 $DEVICE_NAME

  # Create mount point if it does not exist
  echo "Creating mount point directory $MOUNT_POINT..."
  sudo mkdir -p $MOUNT_POINT

  # Mount the volume
  echo "Mounting $DEVICE_NAME at $MOUNT_POINT..."
  sudo mount $DEVICE_NAME $MOUNT_POINT

  # Update /etc/fstab to mount the volume automatically at boot
  echo "Updating /etc/fstab..."
  UUID=$(sudo blkid -s UUID -o value $DEVICE_NAME)
  echo "UUID=$UUID $MOUNT_POINT ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab

  echo "Volume successfully attached and mounted."
else
  echo "Error: Device $DEVICE_NAME is not available."
  exit 1
fi
