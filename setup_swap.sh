#!/bin/bash

# Function to print the message in color
print_info() {
    echo -e "\033[1;32m$1\033[0m"
}

# Function to print an error message in red
print_error() {
    echo -e "\033[1;31m$1\033[0m"
}

print_info "Please make sure you're running this script as root."
print_info "This script is created by Rizzler and sponsored by Quvo.pro"

# Check if swap is currently enabled
swap_exists() {
    swapon --show | grep -q '/swapfile'
}

# Function to remove existing swap file
remove_existing_swap() {
    if swap_exists; then
        print_info "Removing existing swap file..."
        
        # Disable the swap file
        swapoff /swapfile
        
        # Remove the swap file entry from fstab
        sed -i '/\/swapfile/d' /etc/fstab
        
        # Remove the swap file
        rm -f /swapfile
        
        print_info "Existing swap file removed."
    fi
}

# Function to create swap file
create_swap() {
    # Remove existing swap file if any
    remove_existing_swap

    # Prompt user for swap size
    read -p "Enter the size of the swap file (e.g., 1G for 1 gigabyte): " swap_size

    print_info "Creating a ${swap_size} swap file..."

    # Create swap file
    fallocate -l ${swap_size} /swapfile

    # Secure the swap file
    chmod 600 /swapfile

    # Set up the swap space
    mkswap /swapfile

    # Enable the swap file
    swapon /swapfile

    # Backup fstab
    print_info "Backing up /etc/fstab to /etc/fstab.bak..."
    cp /etc/fstab /etc/fstab.bak

    # Add swap entry to fstab
    print_info "Adding swap entry to /etc/fstab..."
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

    # Set swap parameters
    print_info "Setting swap parameters..."
    sysctl vm.swappiness=10
    sysctl vm.vfs_cache_pressure=50

    # Update sysctl configuration file
    print_info "Updating /etc/sysctl.conf with swap parameters..."
    {
        echo 'vm.swappiness=10'
        echo 'vm.vfs_cache_pressure=50'
    } | tee -a /etc/sysctl.conf

    print_info "Swap file setup is complete."
}

# Function to remove swap file
remove_swap() {
    if ! swap_exists; then
        print_error "No swap file is currently mounted at /swapfile."
        print_info "The script will now exit."
        exit 1
    fi

    print_info "Removing the swap file..."

    # Disable the swap file
    swapoff /swapfile

    # Remove the swap file entry from fstab
    sed -i '/\/swapfile/d' /etc/fstab

    # Remove the swap file
    rm -f /swapfile

    print_info "Swap file removed successfully."
}

# Main menu
echo "Choose an option:"
echo "1) Create a swap file"
echo "2) Remove the swap file"
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        create_swap
        ;;
    2)
        remove_swap
        ;;
    *)
        print_error "Invalid choice. Exiting script."
        exit 1
        ;;
esac
