#!/bin/bash

# Read the current value of animations:enabled
STATE=$(hyprctl getoption animations:enabled | grep "int:" | awk '{print $2}')

# Fallback if "int:" doesn't exist (boolean output)
if [ -z "$STATE" ]; then
    STATE=$(hyprctl getoption animations:enabled | grep "false")
    if [ -n "$STATE" ]; then
        STATE=0
    else
        STATE=1
    fi
fi

if [ "$STATE" -eq 0 ]; then
    # Already disabled → reload Hyprland
    hyprctl reload
    powerprofilesctl set balanced
    killall -CONT waybar 2>/dev/null
else
    # Enabled → disable everything
    hyprctl --batch \
        "keyword animations:enabled 0; \
         keyword decoration:shadow:enabled 0; \
         keyword decoration:blur:enabled 0; \
         keyword general:gaps_in 0; \
         keyword general:gaps_out 0; \
         keyword general:border_size 1; \
         keyword decoration:rounding 0; \
         keyword general:allow_tearing 1"
    powerprofilesctl set performance
    killall -STOP waybar 2>/dev/null
fi