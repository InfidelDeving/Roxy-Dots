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
install_yay_packages vesktop teams-for-linux hyprshot hyprlock pywal

# === Build and install Waterfox from source ===
echo "🛠️ Building Waterfox from source..."

# Install build dependencies
install_pacman_packages git base-devel autoconf2.13 unzip zip nodejs npm python rust clang llvm libpulse dbus-glib gtk3 icu lld mesa gtk2 libvpx libnotify nss

BUILD_DIR="/tmp/waterfox-build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Clone and configure
git clone https://github.com/WaterfoxCo/Waterfox.git
cd Waterfox

cat > .mozconfig <<EOF
ac_add_options --enable-release
ac_add_options --enable-optimize
ac_add_options --enable-default-toolkit=cairo-gtk3-wayland
ac_add_options --disable-debug
mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj
EOF

./mach bootstrap --application-choice=browser --no-interactive
./mach build

# Install
echo "📦 Installing Waterfox..."
sudo mkdir -p /opt/waterfox
sudo cp -r obj/dist/bin/* /opt/waterfox/
sudo ln -sf /opt/waterfox/waterfox /usr/local/bin/waterfox

# Desktop entry
echo "🖥️ Creating Waterfox desktop entry..."
cat | sudo tee /usr/share/applications/waterfox.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Waterfox
Comment=Privacy-focused web browser
Exec=/opt/waterfox/waterfox %u
Icon=/opt/waterfox/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOF

cd -

echo "🛠️ Enabling services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable sddm

# Hyprland session
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

# === Download RoxyGrub and RoxySDDM from GitHub ===
echo "🔽 Downloading RoxyGrub and RoxySDDM themes from GitHub..."

# Create a temporary directory for the repository
TEMP_DIR=$(mktemp -d)
git clone https://github.com/InfidelDeving/Roxy-Dots.git "$TEMP_DIR"

# === GRUB Theme ===
if [ -d "$TEMP_DIR/RoxyGrub" ] && [ -f "$TEMP_DIR/RoxyGrub/theme.txt" ]; then
    echo "📦 Installing GRUB theme..."
    sudo mkdir -p /usr/share/grub/themes
    sudo cp -r "$TEMP_DIR/RoxyGrub" /usr/share/grub/themes/
    sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
    echo 'GRUB_THEME="/usr/share/grub/themes/RoxyGrub/theme.txt"' | sudo tee -a /etc/default/grub

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
if [ -d "$TEMP_DIR/RoxySDDM" ] && [ -f "$TEMP_DIR/RoxySDDM/theme.conf" ]; then
    echo "📦 Installing SDDM theme..."
    sudo mkdir -p /usr/share/sddm/themes
    sudo cp -r "$TEMP_DIR/RoxySDDM" /usr/share/sddm/themes/

    echo "📝 Setting SDDM theme to RoxySDDM..."
    sudo mkdir -p /etc/sddm.conf.d
    echo "[Theme]" | sudo tee /etc/sddm.conf.d/roxy.conf
    echo "Current=RoxySDDM" | sudo tee -a /etc/sddm.conf.d/roxy.conf
else
    echo "⚠️ RoxySDDM theme not found or missing theme.conf – skipping SDDM theming."
fi

# === Download and Install Configs from GitHub ===
echo "🔽 Downloading config files from GitHub..."

# Download configuration files
CONFIG_REPO="https://github.com/InfidelDeving/Roxy-Dots.git"
CONFIG_DIRS=(fastfetch hypr kitty rofi vesktop wal waybar)

# Create .config directory if not exists
mkdir -p "$HOME/.config"

# Download and copy files
for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$TEMP_DIR/$dir" ]; then
        echo "→ Downloading $dir to ~/.config/"
        sudo cp -r "$TEMP_DIR/$dir" "$HOME/.config/"
    else
        echo "⚠️ Skipped $dir – not found in the repository."
    fi
done

# Copy .bashrc from the repo to home directory
echo "→ Downloading .bashrc to $HOME/"
cp "$TEMP_DIR/.bashrc" "$HOME/.bashrc"  # No sudo needed here

# Clean up temporary directory
rm -rf "$TEMP_DIR"

# Fix permissions
sudo chown -R "$(whoami)":"$(whoami)" "$HOME/.config" "$HOME/.bashrc"

echo ""
echo "✅ Setup complete!"
echo "👉 Select 'Hyprland' in the SDDM login screen."
echo "👉 GRUB and SDDM themes applied (if files found)."
echo "👉 Waterfox installed to /opt/waterfox and available as 'waterfox'."
echo "👉 Configs downloaded and copied to ~/.config/ and .bashrc updated."
echo "👉 If AUR packages failed, re-run: yay -S <package>"
