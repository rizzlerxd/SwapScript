#!/bin/bash

# Display a welcome message
echo "Please ensure you are running this script as root."
echo "This script is created by Rizzler and sponsored by quvo.pro."

# Function to check if swap file exists
function check_existing_swap() {
    if [[ -e /swapfile || -e /swap.img ]]; then
        echo "Existing swap file detected. Removing it..."
        sudo swapoff /swapfile 2>/dev/null || true
        sudo rm -f /swapfile
        sudo rm -f /swap.img
        sudo sed -i '/\/swapfile/d' /etc/fstab 2>/dev/null || true
        echo "Existing swap file removed."
    fi
}

# Function to create a swap file
function create_swap() {
    read -p "Enter the size of the swap file (e.g., 1G for 1 gigabyte, 512M for 512 megabytes): " size

    # Append 'G' if no unit is specified
    if [[ ! $size =~ ^[0-9]+[MG]$ ]]; then
        size="${size}G"
    fi

    # Validate size input
    if [[ ! $size =~ ^[0-9]+[MG]$ ]]; then
        echo "Invalid size. Please specify size in megabytes (M) or gigabytes (G)."
        exit 1
    fi

    # Create swap file
    echo "Creating a swap file of size $size..."
    sudo fallocate -l "$size" /swapfile
    if [[ $? -ne 0 ]]; then
        echo "Error creating swap file. Please ensure you have sufficient disk space."
        exit 1
    fi

    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    if [[ $? -ne 0 ]]; then
        echo "Failed to format swap file. It may be corrupted or too small."
        exit 1
    fi

    sudo swapon /swapfile
    if [[ $? -ne 0 ]]; then
        echo "Failed to enable swap file."
        exit 1
    fi

    # Update /etc/fstab
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

    # Update system configuration
    sudo sysctl vm.swappiness=10
    sudo sysctl vm.vfs_cache_pressure=50
    sudo bash -c "echo 'vm.swappiness=10' >> /etc/sysctl.conf"
    sudo bash -c "echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.conf"

    echo "Swap file created and system configuration updated."
}

# Main logic
check_existing_swap
create_swap
