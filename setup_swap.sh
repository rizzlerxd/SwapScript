#!/bin/bash

# Display a welcome message with sponsor information
echo "Please make sure you are running this script as root."
echo "Script made by Rizzler, sponsored by Quvo.pro."
echo

# Prompt the user for the amount of swap to add
read -p "Enter the amount of swap space to add (e.g., 1G for 1 gigabyte): " swap_size

# Validate input
if [[ -z "$swap_size" ]]; then
    echo "No size entered. Exiting."
    exit 1
fi

echo "Creating a swap file of size $swap_size..."
# Create the swap file
sudo fallocate -l "$swap_size" /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "Swap file created and activated."

# Backup fstab and add swap file entry
echo "Backing up /etc/fstab to /etc/fstab.bak..."
sudo cp /etc/fstab /etc/fstab.bak
echo "Adding swap file entry to /etc/fstab..."
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
echo "Swap file entry added to /etc/fstab."

# Set swap parameters
echo "Setting swap parameters..."
sudo sysctl vm.swappiness=10
sudo sysctl vm.vfs_cache_pressure=50

# Update sysctl configuration
echo "Updating /etc/sysctl.conf with new parameters..."
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf

# Reload sysctl configuration
echo "Reloading sysctl configuration..."
sudo sysctl -p
echo "Sysctl configuration reloaded."

echo "Swap setup complete."
