#!/usr/bin/env bash
set -e

# -----------------------------
# Helpers
# -----------------------------
pacman_install() {
  sudo pacman -S --needed --noconfirm "$@"
}

yay_install() {
  yay -S --needed --noconfirm "$@"
}

service_user_enable() {
  systemctl --user is-enabled "$1" &>/dev/null || \
  systemctl --user enable --now "$1"
}

# -----------------------------
# Enable multilib
# -----------------------------
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
  echo "==> Enabling multilib..."
  sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
  sudo pacman -Sy --noconfirm
fi

# -----------------------------
# System update
# -----------------------------
echo "==> Updating system..."
sudo pacman -Syu --noconfirm

# -----------------------------
# Base packages
# -----------------------------
pacman_install \
  base-devel git \
  wayland wayland-protocols \
  xorg-xwayland xorg-xhost \
  pipewire wireplumber \
  pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack \
  lib32-pipewire lib32-pipewire-jack lib32-libpulse \
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  polkit-gnome \
  zsh zsh-autosuggestions zsh-syntax-highlighting \
  nautilus gparted \
  rofi waybar slurp grim cliphist hyprlock hypridle \
  qalculate-gtk btop cava neovim \
  gnome-clocks gnome-text-editor \
  inter-font noto-fonts-emoji nerd-fonts noto-fonts-cjk \
  adw-gtk-theme ntfs-3g \
  wine wine-mono wine-gecko winetricks \
  ffmpeg gamescope telegram-desktop \
  gst-plugins-{base,good,bad,ugly} \
  samba gnutls sdl2-compat \
  virtualbox virtualbox-host-modules-arch \

sudo modprobe vboxdrv
sudo modprobe vboxnetflt
sudo modprobe vboxnetadp

# -----------------------------
# Remove bad portal
# -----------------------------
sudo pacman -Rns --noconfirm xdg-desktop-portal-wlr 2>/dev/null || true

# -----------------------------
# Enable PipeWire
# -----------------------------
service_user_enable pipewire.service
service_user_enable wireplumber.service
service_user_enable pipewire-pulse.socket
service_user_enable pipewire-pulse.service

# -----------------------------
# NvChad setup
# -----------------------------
NVIM_DIR="$HOME/.config/nvim"

if [ ! -d "$NVIM_DIR" ]; then
  echo "==> Installing NvChad..."
  git clone https://github.com/NvChad/starter "$NVIM_DIR"
else
  echo "==> NvChad already installed"
fi

INIT_LUA="$NVIM_DIR/init.lua"

if ! grep -q "Load matugen colors" "$INIT_LUA" 2>/dev/null; then
  cat >> "$INIT_LUA" <<'EOF'

-- Load matugen colors after startup
vim.schedule(function()
  require "mappings"
  local colors = vim.fn.stdpath("config") .. "/colors.lua"
  if vim.fn.filereadable(colors) == 1 then
    dofile(colors)
  end
end)
EOF
fi

COLORS_LUA="$NVIM_DIR/colors.lua"
[ -f "$COLORS_LUA" ] || touch "$COLORS_LUA"

# -----------------------------
# Install yay
# -----------------------------
if ! command -v yay &>/dev/null; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
fi

# -----------------------------
# AUR packages
# -----------------------------
yay_install \
  brave-bin \
  waypaper \
  pavucontrol \
  bibata-cursor-theme-bin \
  heroic-games-launcher-bin \
  hyprland-plugin-hyprbars-git \
  elecwhat-bin \
  ttf-symbola \
  wttrbar

# -----------------------------
# Flatpak
# -----------------------------
flatpak install -y flathub org.vinegarhq.Sober || true

# -----------------------------
# Nautilus default
# -----------------------------
xdg-mime query default inode/directory | grep -q Nautilus || \
xdg-mime default org.gnome.Nautilus.desktop inode/directory

# -----------------------------
# Root GTK theming
# -----------------------------
sudo mkdir -p /root/.config
sudo ln -sf ~/.config/gtk-3.0 /root/.config/
sudo ln -sf ~/.config/gtk-4.0 /root/.config/

# -----------------------------
# X access for root apps
# -----------------------------
xhost +SI:localuser:root || true

# -----------------------------
# Time & NTP
# -----------------------------
sudo timedatectl set-timezone Asia/Riyadh
sudo timedatectl set-local-rtc 1 --adjust-system-clock
sudo timedatectl set-ntp true

timedatectl status | grep -E "Time zone|System clock synchronized|NTP service"

echo
echo "✅ Setup complete."

# -----------------------------
# Reboot confirmation
# -----------------------------
read -rp "🔄 Reboot now? [y/N]: " REBOOT_CONFIRM
if [[ "$REBOOT_CONFIRM" =~ ^[Yy]$ ]]; then
  sudo reboot
else
  echo "Reboot skipped."
fi
