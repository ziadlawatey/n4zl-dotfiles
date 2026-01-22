#!/bin/bash

RAW_PATH=$(grep "^wallpaper" ~/.config/waypaper/config.ini | cut -d '=' -f2- | xargs)
WALLPAPER=$(eval echo "$RAW_PATH")

if [ ! -f "$WALLPAPER" ]; then
    echo "Wallpaper file not found: $WALLPAPER"
    exit 1
fi

ln -sf "$WALLPAPER" ~/.config/waypaper/current_wallpaper

# notify-send "Changing Theme" "Applying new wallpaper and updating colors, please wait until confirmation..."

# ----------------------------------------------------------------------------
# Dependency Check
# ----------------------------------------------------------------------------

if ! command -v matugen &> /dev/null; then
    echo "❌ Error: matugen is not installed"
    exit 1
fi

# ----------------------------------------------------------------------------
# Generate Theme with Matugen
# ----------------------------------------------------------------------------

if ! matugen image "$WALLPAPER"; then
    echo "❌ Error: matugen failed to generate theme"
    exit 1
fi

matugen image "$WALLPAPER" &&  ~/.local/bin/matugen_and_reload.sh


notify-send "Theme Applied" "Wallpaper and theme updated successfully!"

