#!/bin/bash

# Find Windows Boot Manager entry
WIN_BOOT_ENTRY=$(sudo efibootmgr | grep "Windows Boot Manager" | awk '{print $1}' | sed 's/Boot//;s/\*//')

if [[ -n "$WIN_BOOT_ENTRY" ]]; then
    echo "Rebooting into Windows (Boot$WIN_BOOT_ENTRY)..."
    sudo efibootmgr --bootnext $WIN_BOOT_ENTRY
    systemctl reboot
else
    echo "Windows Boot Manager not found!"
    exit 1
fi