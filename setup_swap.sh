#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

echo "Made by Rizzler, sponsored by Quvo.pro"

# Prompt user for action
read -p "Do you want to (a)dd or (r)emove swap? (Enter 'a' for add or 'r' for remove): " ACTION

if [[ "$ACTION" == "a" ]]; then
    echo "Creating swap file..."

    # Prompt user for swap size
    read -p "Enter the size of swap file (e.g., 1G, 512M, or just a number for megabytes): " SWAP_SIZE

    # Check if user provided a unit; default to megabytes if not
    if [[ ! "$SWAP_SIZE" =~ ^[0-9]+[G|M]?$ ]]; then
        SWAP_SIZE="${SWAP_SIZE}M"
    fi

    # Convert to megabytes if user provided a size in gigabytes
    if [[ "$SWAP_SIZE" =~ ^[0-9]+G$ ]]; then
        SWAP_SIZE=$(echo "$SWAP_SIZE" | sed 's/G//')
        SWAP_SIZE=$(expr $SWAP_SIZE \* 1024)M
    fi

    echo "Creating swap file of size ${SWAP_SIZE}..."

    # Remove existing swap file if it exists
    if [ -f /swapfile ]; then
        echo "Removing existing swap file..."
        swapoff /swapfile
        rm -f /swapfile
    fi

    # Create swap file
    fallocate -l ${SWAP_SIZE} /swapfile 2>/dev/null

    # Check if fallocate was successful, otherwise use dd
    if [ ! -f /swapfile ]; then
        echo "fallocate failed, using dd to create swap file..."
        dd if=/dev/zero of=/swapfile bs=1M count=${SWAP_SIZE%M} 2>/dev/null
    fi

    chmod 600 /swapfile
    mkswap /swapfile 2>/dev/null

    # Check if mkswap was successful
    if [ $? -ne 0 ]; then
        echo "Error creating swap space. Please ensure the size is at least 40 KiB."
        rm -f /swapfile
        exit 1
    fi

    swapon /swapfile

    # Backup and update fstab
    cp /etc/fstab /etc/fstab.bak
    grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

    # Update sysctl.conf
    if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
        echo "vm.swappiness=10" >> /etc/sysctl.conf
    fi

    if ! grep -q "vm.vfs_cache_pressure" /etc/sysctl.conf; then
        echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf
    fi

    sysctl -p

    echo "Swap file created and enabled successfully."

elif [[ "$ACTION" == "r" ]]; then
    echo "Removing swap file..."

    # Check if swap file exists
    if [ -f /swapfile ]; then
        swapoff /swapfile
        rm -f /swapfile
        sed -i '/\/swapfile/d' /etc/fstab
        echo "Swap file removed successfully."
    else
        echo "No swap file found to remove."
    fi

else
    echo "Invalid option. Please enter 'a' to add or 'r' to remove swap."
    exit 1
fi
