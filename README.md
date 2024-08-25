# Swap File Management Script

This script allows you to easily create or remove a swap file on your Linux system. You can specify the size of the swap file you want to create. The script also handles existing swap files and updates system configurations accordingly.

## Features

- **Create a Swap File**: Specify the size of the swap file to be created (e.g., 1G for 1 gigabyte).
- **Remove an Existing Swap File**: Remove the existing swap file and update the system configuration.
- **Handles Existing Swap Files**: Automatically removes any existing swap file before creating a new one.
- **Updates System Configuration**: Adjusts `vm.swappiness` and `vm.vfs_cache_pressure` settings and updates `/etc/sysctl.conf`.

## Usage

### Running the Script

You can easily run the script using the following `curl` command:

```bash
bash <(curl -s https://raw.githubusercontent.com/rizzlerxd/AddSwap/main/setup_swap.sh)
