# Setup Swap Script

## Overview

The `setup_swap.sh` script is designed to help you easily add swap space to your Linux system. It allows you to specify the amount of swap space in gigabytes (GB) and configures your system accordingly. The script sets up the swap file, updates system configurations, and ensures that your settings persist across reboots.

## Features

- **User Input:** Prompts you to specify the size of the swap file you wish to create.
- **Swap File Creation:** Creates a swap file of the specified size.
- **System Configuration:** Configures the swap file, updates `/etc/fstab` for persistence, and applies system settings.
- **Persistent Settings:** Updates `/etc/sysctl.conf` to make swappiness and cache pressure settings persistent across reboots.

## How to Use

1. **Download the Script**

   You can directly execute the script using `curl`:

   ```bash
   bash <(curl -s https://raw.githubusercontent.com/rizzlerxd/AddSwap/main/setup_swap.sh)
