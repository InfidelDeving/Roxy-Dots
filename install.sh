#!/bin/bash

# Set HOME directory explicitly in the script
USER_HOME=$(eval echo ~$USER)

# Ensure that the script is in the user's home directory or subdirectories
if [[ ! "$PWD" =~ ^$USER_HOME/ ]]; then
    echo "This script should be run from within the user's home directory or a subdirectory!"
    exit 1
fi

# Install yay if not already installed
if ! command -v yay &> /dev/null; then
    echo "yay is not installed. Installing yay..."
    sudo pacman -S --noconfirm yay
fi

# Install the required packages
echo "Installing required packages..."
yay -S --noconfirm fastfetch kitty rofi vesktop waybar nm-applet hyprpaper mpvpaper hyprpolkit hyprlock hyprshot teams-for-linux

# Ensure necessary directories exist
echo "Ensuring required directories exist..."
mkdir -p "$USER_HOME/.config" "$USER_HOME/.local/share/sddm/themes" "$USER_HOME/.config/grub"

# Copy configuration files to $USER_HOME/.config
echo "Copying configuration files..."
cp -r hypr kitty fastfetch rofi vesktop waybar "$USER_HOME/.config"

# Copy RoxyGrub to /usr/share/grub/themes/
GRUB_THEMES_DIR="/usr/share/grub/themes"
echo "Copying RoxyGrub to GRUB themes directory..."

# Make sure to ask for root privileges to copy files into system directories
if [ ! -d "$GRUB_THEMES_DIR" ]; then
    sudo mkdir -p "$GRUB_THEMES_DIR"
fi

# Copy the RoxyGrub folder directly into /usr/share/grub/themes/
sudo cp -r RoxyGrub "$GRUB_THEMES_DIR/"

# Modify GRUB config to use the new theme
echo "Modifying GRUB config to use RoxyGrub theme..."

GRUB_CONFIG="/etc/default/grub"
if [ ! -f "$GRUB_CONFIG" ]; then
    echo "GRUB config not found. Please check your GRUB installation."
    exit 1
fi

# Replace or add the theme entry in /etc/default/grub
sudo sed -i '/^GRUB_THEME=/c\GRUB_THEME="/usr/share/grub/themes/RoxyGrub/theme.txt"' "$GRUB_CONFIG"

# Rebuild GRUB (this requires root privileges)
echo "Rebuilding GRUB configuration..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Copy RoxySDDM to SDDM themes directory (local user space)
ROXYSDDM_DIR="$USER_HOME/.local/share/sddm/themes/RoxySDDM"
echo "Copying RoxySDDM to SDDM themes directory..."
cp -r RoxySDDM "$ROXYSDDM_DIR"

# Create SDDM config if it does not exist
SDDM_CONFIG="$USER_HOME/.config/sddm.conf"
if [ ! -f "$SDDM_CONFIG" ]; then
    echo "Creating basic SDDM config file..."
    echo "Current=RoxySDDM" > "$SDDM_CONFIG"
fi

# Copy .bashrc to $USER_HOME
echo "Copying .bashrc to $USER_HOME..."
cp .bashrc "$USER_HOME/.bashrc"

# Reload SDDM (you may need to restart your session or SDDM manually)
echo "SDDM reloaded. Please restart your session or SDDM service manually to apply changes."

echo "Setup complete!"
