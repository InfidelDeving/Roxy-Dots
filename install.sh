#!/bin/bash

# install.sh - Set up Hyprland desktop on fresh minimal Arch Linux

set -e

echo "🔄 Updating system packages..."
sudo pacman -Syu --noconfirm

# Helper: Install pacman packages
install_pacman_packages() {
    echo "📦 Installing: $*"
    sudo pacman -S --noconfirm --needed "$@"
}

# Helper: Install yay packages
install_yay_packages() {
    echo "📦 Installing AUR: $*"
    yay -S --noconfirm --needed "$@"
}

# Ensure yay is installed
if ! command -v yay &> /dev/null; then
    echo "📥 yay not found, installing..."
    sudo pacman -S --noconfirm --needed base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
fi

echo "🚀 Installing general dependencies..."
install_pacman_packages hyprland fastfetch sddm

echo "🖼️ Installing Wayland/Hyprland support..."
install_pacman_packages wayland wayland-protocols xdg-desktop-portal xdg-desktop-portal-hyprland wlroots

echo "🔌 Installing autorun services..."
install_pacman_packages networkmanager network-manager-applet
install_yay_packages waybar-cava hyprpaper mpvpaper hyprpolkit

echo "🧷 Installing bind applications..."
install_pacman_packages kitty dolphin rofi
install_yay_packages waterfox vesktop teams-for-linux hyprshot hyprlock

echo "🛠️ Enabling services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable sddm

# Create Hyprland session for SDDM
echo "📁 Setting up Hyprland session..."
sudo mkdir -p /usr/share/wayland-sessions
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF

# === GRUB Theme ===
echo "🎨 Installing GRUB theme..."
sudo mkdir -p /usr/share/grub/themes
sudo cp -r RoxyGrub /usr/share/grub/themes/
sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
echo 'GRUB_THEME="/usr/share/grub/themes/RoxyGrub/theme.txt"' | sudo tee -a /etc/default/grub

# Regenerate GRUB config
if [ -d /boot/grub ]; then
    echo "🔁 Regenerating GRUB config..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
elif [ -d /boot/efi ]; then
    echo "🔁 Regenerating GRUB config (EFI)..."
    sudo grub-mkconfig -o /boot/efi/EFI/grub/grub.cfg
else
    echo "⚠️ GRUB folder not found. Regenerate GRUB config manually."
fi

# === SDDM Theme ===
echo "🎨 Installing SDDM theme..."
sudo mkdir -p /usr/share/sddm/themes
sudo cp -r RoxySDDM /usr/share/sddm/themes/

SDDM_CONF="/usr/lib/sddm/sddm.conf.d/default.conf"
if [ -f "$SDDM_CONF" ]; then
    sudo sed -i '/^Current=/d' "$SDDM_CONF"
    echo 'Current=RoxySDDM' | sudo tee -a "$SDDM_CONF"
else
    echo "[Theme]" | sudo tee "$SDDM_CONF"
    echo "Current=RoxySDDM" | sudo tee -a "$SDDM_CONF"
fi

# === Config Files ===
echo "📁 Copying config directories to ~/.config..."
CONFIG_DIRS=(fastfetch hypr kitty rofi vesktop wal waybar)

mkdir -p "$HOME/.config"

for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "→ Copying $dir to ~/.config/"
        cp -r "$dir" "$HOME/.config/"
    else
        echo "⚠️ Skipped $dir – not found."
    fi
done

chown -R "$(whoami)":"$(whoami)" "$HOME/.config"

# === Done ===
echo ""
echo "✅ Setup complete!"
echo "👉 Select 'Hyprland' in the SDDM login screen."
echo "👉 Custom themes applied for GRUB and SDDM."
echo "👉 Configs copied to ~/.config/"
echo "👉 If AUR packages failed, re-run: yay -S <package>"
