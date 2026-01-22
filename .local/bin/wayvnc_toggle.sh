#!/usr/bin/env zsh

CONFIG_FILE=~/.config/hypr/hyprland/monitors.conf
RES_FILE="/mnt/overall_storage/devices_resolutions.txt"

# Function to save resolution
save_resolution() {
    local device="$1"
    local resolution="$2"
    # Remove old entry
    sed -i "/^$device=/d" "$RES_FILE" 2>/dev/null
    echo "$device=$resolution" >> "$RES_FILE"
}

WIFI_IP=$(
  ip -4 addr show | awk '
  /^[0-9]+: (wlan|wlp)/ {wifi=1}
  /^[0-9]+: / && !/ (wlan|wlp)/ {wifi=0}
  wifi && /inet / {
      sub(/\/.*/, "", $2)
      print $2
      exit
  }'
)

if [ -z "$WIFI_IP" ]; then
    echo "Failed to detect Wi-Fi IP"
    exit 1
fi


# Function to load resolution
load_resolution() {
    local device="$1"
    if [ -f "$RES_FILE" ]; then
        grep "^$device=" "$RES_FILE" | cut -d'=' -f2
    fi
}

# Toggle off if running
if pgrep -x wayvnc > /dev/null; then
    HEADLESS=$(hyprctl monitors | grep "Monitor HEADLESS" | awk '{print $2}')

    pkill -9 wayvnc
    sleep 0.5

    if [ -n "$HEADLESS" ]; then
        hyprctl output remove "$HEADLESS"
    fi

    sed -i "/HEADLESS/d" "$CONFIG_FILE"
    echo "VNC stopped"
    exit 0
fi

# Create headless output
HEADLESS=$(hyprctl monitors | grep "Monitor HEADLESS" | awk '{print $2}')

if [ -z "$HEADLESS" ]; then
    hyprctl output create headless
    sleep 1
    HEADLESS=$(hyprctl monitors | grep "Monitor HEADLESS" | awk '{print $2}')
fi

TABLET_RESOLUTION=""

# Check if ADB works
if command -v adb &> /dev/null && adb devices | grep -q "device$"; then
    RAW_RES=$(adb shell wm size | awk '/Physical size/ {print $3}')
    ORIENTATION=$(adb shell dumpsys input | grep 'SurfaceOrientation' | awk '{print $NF}')

    WIDTH=${RAW_RES%x*}
    HEIGHT=${RAW_RES#*x}

    if [ "$ORIENTATION" -eq 1 ] || [ "$ORIENTATION" -eq 3 ]; then
        TABLET_RESOLUTION="${HEIGHT}x${WIDTH}"
    else
        TABLET_RESOLUTION="${WIDTH}x${HEIGHT}"
    fi

    echo "Detected tablet resolution via ADB: $TABLET_RESOLUTION"

    # Save resolution
    save_resolution "tablet" "$TABLET_RESOLUTION"
else
    # Try to load stored resolution
    STORED_RES=$(load_resolution "tablet")
    if [ -n "$STORED_RES" ]; then
        TABLET_RESOLUTION="$STORED_RES"
        echo "Using stored tablet resolution: $TABLET_RESOLUTION"
    else
        # Fallback default
        TABLET_RESOLUTION="1920x1200"
        echo "Using default resolution: $TABLET_RESOLUTION"
    fi
fi

RESOLUTION="${TABLET_RESOLUTION}@60"

# Start wayvnc
(wayvnc -o "$HEADLESS" "$WIFI_IP" -g > /dev/null 2>&1 &)

sleep 0.5

# Remove any old HEADLESS line from config first
sed -i "/HEADLESS/d" "$CONFIG_FILE"

# Get main monitor name
MAIN_MONITOR=$(hyprctl monitors | grep "Monitor" | grep -v "HEADLESS" | head -n1 | awk '{print $2}')

# Force main monitor at 0x0
hyprctl keyword monitor "$MAIN_MONITOR, preferred, 0x0, 1"

# Place tablet to the LEFT
X_OFFSET="-${TABLET_RESOLUTION%x*}x0"
echo "monitor=$HEADLESS, $RESOLUTION, $X_OFFSET, 1" >> "$CONFIG_FILE"

echo "VNC started on $HEADLESS with resolution $RESOLUTION"
