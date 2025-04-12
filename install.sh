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
    if [ -d "/tmp/yay" ]; then
        echo "⚠️ Removing existing /tmp/yay folder..."
        sudo rm -rf /tmp/yay
    fi
    sudo pacman -S --noconfirm --needed base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    CUR_DIR=$(pwd)
    cd /tmp/yay
    makepkg -si --noconfirm
    cd "$CUR_DIR"
fi

echo "🚀 Installing general dependencies..."
install_pacman_packages hyprland fastfetch sddm

echo "🖼️ Installing Wayland/Hyprland support..."
install_pacman_packages wayland wayland-protocols xdg-desktop-portal xdg-desktop-portal-hyprland wlroots xorg-xwayland

echo "🔌 Installing autorun services..."
install_pacman_packages networkmanager network-manager-applet
install_yay_packages waybar-cava hyprpaper mpvpaper hyprpolkit

echo "🧷 Installing bind applications..."
install_pacman_packages kitty dolphin rofi
install_yay_packages waterfox vesktop teams-for-linux hyprshot hyprlock

echo "🛠️ Enabling services..."
sudo systemctl enable --now NetworkManager

if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "🔁 Enabling SDDM (will start on next boot)..."
    sudo systemctl enable sddm
else
    echo "⚡ Enabling and starting SDDM now..."
    sudo systemctl enable --now sddm
fi

# Create Hyprland session for SDDM if not exists
if [ ! -f /usr/share/wayland-sessions/hyprland.desktop ]; then
    echo "📁 Creating Hyprland session..."
    sudo mkdir -p /usr/share/wayland-sessions
    sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF
fi

# === GRUB Theme ===
echo "🎨 Installing GRUB theme..."
if [ -d "RoxyGrub" ] && [ -f "RoxyGrub/theme.txt" ]; then
    sudo mkdir -p /usr/share/grub/themes
    sudo cp -r RoxyGrub /usr/share/grub/themes/
    sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
    echo 'GRUB_THEME="/usr/share/grub/themes/RoxyGrub/theme.txt"' | sudo tee -a /etc/default/grub

    # Regenerate GRUB config
    if [ -d /boot/grub ]; then
        echo "🔁 Regenerating GRUB config..."
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    elif [ -d /boot/efi ]; then
        echo "🔁 Regenerating GRUB config (EFI fallback)..."
        sudo grub-mkconfig -o /boot/efi/grub/grub.cfg
    else
        echo "⚠️ GRUB folder not found. Regenerate GRUB config manually."
    fi
else
    echo "⚠️ RoxyGrub theme not found or missing theme.txt – skipping GRUB theming."
fi

# === SDDM Theme ===
echo "🎨 Installing SDDM theme..."
if [ -d "RoxySDDM" ] && [ -f "RoxySDDM/theme.conf" ]; then
    sudo mkdir -p /usr/share/sddm/themes
    sudo cp -r RoxySDDM /usr/share/sddm/themes/

    echo "📝 Setting SDDM theme to RoxySDDM..."
    sudo mkdir -p /etc/sddm.conf.d
    echo "[Theme]" | sudo tee /etc/sddm.conf.d/roxy.conf
    echo "Current=RoxySDDM" | sudo tee -a /etc/sddm.conf.d/roxy.conf
else
    echo "⚠️ RoxySDDM theme not found or missing theme.conf – skipping SDDM theming."
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

# Copy .bashrc safely
echo "📁 Backing up and copying .bashrc to $HOME/"
if [ -f "$HOME/.bashrc" ]; then
    cp "$HOME/.bashrc" "$HOME/.bashrc.backup"
fi
cp .bashrc "$HOME/.bashrc"

# Fix permissions
chown -R "$(whoami)":"$(whoami)" "$HOME/.config" "$HOME/.bashrc"

echo ""
echo "✅ Setup complete!"
echo "👉 Select 'Hyprland' in the SDDM login screen."
echo "👉 Custom themes applied for GRUB and SDDM (if files found)."
echo "👉 Configs copied to ~/.config/"
echo "👉 .bashrc copied (backup created if needed)."
echo "👉 If AUR packages failed, re-run: yay -S <package>"
