#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 <swap-size-in-GB>"
    echo "Example: $0 1  # This will create a 1GB swap file"
    exit 1
}

# Check if the script is run as root
if [ "$(id -u)" -ne "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    usage
fi

# Check if the argument is a positive integer
SWAP_SIZE_GB="$1"
if ! [[ "$SWAP_SIZE_GB" =~ ^[0-9]+$ ]] || [ "$SWAP_SIZE_GB" -le 0 ]; then
    echo "Error: Swap size must be a positive integer." 1>&2
    usage
fi

# Create a swap file
echo "Creating a swap file of size ${SWAP_SIZE_GB}G..."
fallocate -l ${SWAP_SIZE_GB}G /swapfile

# Set permissions for the swap file
echo "Setting permissions for the swap file..."
chmod 600 /swapfile

# Set up the swap space
echo "Setting up the swap space..."
mkswap /swapfile

# Enable the swap space
echo "Enabling the swap space..."
swapon /swapfile

# Backup the current fstab file
echo "Backing up /etc/fstab..."
cp /etc/fstab /etc/fstab.bak

# Update /etc/fstab to enable swap on boot
echo "Updating /etc/fstab..."
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

# Set system parameters
echo "Setting swappiness and cache pressure..."
sysctl vm.swappiness=10
sysctl vm.vfs_cache_pressure=50

# Update /etc/sysctl.conf
echo "Updating /etc/sysctl.conf..."
{
    echo 'vm.swappiness=10'
    echo 'vm.vfs_cache_pressure=50'
} >> /etc/sysctl.conf

# Apply changes
echo "Applying sysctl changes..."
sysctl -p

# Show swap usage
echo "Swap is now enabled. Current swap usage:"
swapon --show

echo "Swap setup and system configuration completed successfully."
