#!/usr/bin/env bash

# ============================================================================
# Matugen Reload Script
# Reloads apps after wallpaper change without killing them
# ============================================================================

# ----------------------------------------------------------------------------
# Argument Validation
# ----------------------------------------------------------------------------



echo "🎨 Generating theme with matugen..."
echo "✅ Matugen completed successfully"

# ----------------------------------------------------------------------------
# Reload Applications
# ----------------------------------------------------------------------------

echo "🎨 Reloading theme for all apps..."

#!/usr/bin/env bash

# -------- Helper functions --------

kill_if_running() {
    if pgrep -x "$1" >/dev/null; then
        echo "Killing $1..."
        pkill -x "$1"
    fi
}

kill_and_restart() {
    if pgrep -x "$1" >/dev/null; then
        echo "Restarting $1..."
        pkill -x "$1"
        sleep 0.5
        eval "$2" &
    fi
}

# -------- Apps --------

# Kill only (no relaunch)
kill_if_running waypaper

# Kill + relaunch with sudo
if pgrep -x gparted >/dev/null; then
    echo "Restarting gparted with sudo..."
    sudo pkill gparted
    sleep 0.5
    pkexec gparted
fi

# GTK apps you want refreshed
GTK_APPS=(
    nautilus
    gnome-clock
    qalculate-gtk
    pavucontrol
    blueberry
    apostrophe
)

for app in "${GTK_APPS[@]}"; do
    kill_and_restart "$app" "$app"
done

# ---------------------------------------
# Polkit agent reload
# ---------------------------------------
POLKIT="/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"

if pgrep -f "$POLKIT" >/dev/null; then
    echo "Restarting polkit agent"
    pkill -f "$POLKIT"
    sleep 0.5
    "$POLKIT" &
fi

POL="/usr/lib/xdg-desktop-portal-gtk"

if pgrep -f "$POL" >/dev/null; then
    echo "Restarting polkit agent"
    pkill -f "$POL"
    sleep 0.5
    "$POL" &
fi


echo "✔ GTK apps reload complete"


# Reload Spicetify
if pgrep -x "spotify" > /dev/null; then
    echo "🔄 Reloading Spotify theme..."
    spicetify config color_scheme dark
    spicetify apply
    echo "   ✓ Spotify theme applied"
else
    echo "⏭️  Spotify not running, skipping..."
fi

echo "✅ Theme reload complete!"
