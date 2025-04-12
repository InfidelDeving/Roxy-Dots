#!/bin/bash


# This script will install yay from source on an Arch-based system

# Update the system package database and upgrade the system
echo "Updating system packages..."
sudo pacman -Syu --noconfirm

# Install necessary dependencies
echo "Installing dependencies..."
sudo pacman -S --noconfirm base-devel git go

# Clone the yay repository from AUR
echo "Cloning yay repository..."
git clone https://aur.archlinux.org/yay.git

# Navigate into the yay directory
cd yay

# Build and install yay
echo "Building yay..."
makepkg -si --noconfirm

# Clean up
cd ..
rm -rf yay

# Success message
echo "yay has been installed successfully!"

# Update the system
echo "Updating the system..."
sudo pacman -Syu --noconfirm

# Install the packages using yay
echo "Installing packages..."

yay -S --noconfirm fastfetch kitty rofi vesktop waybar-cava nm-applet hyprpaper mpvpaper hyprpolkit hyprlock hyprshot teams-for-linux

echo "Installation complete!"


#!/bin/bash

# Define the list of configuration directories
CONFIG_DIRS=("fastfetch" "hypr" "kitty" "rofi" "vesktop" "waybar")

# Get the current working directory
REPO_DIR="$(pwd)"

# Destination directory
DEST_DIR="$HOME/.config"

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Move each configuration directory
for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$REPO_DIR/$dir" ]; then
        echo "Moving $dir to $DEST_DIR"
        mv "$REPO_DIR/$dir" "$DEST_DIR/"
    else
        echo "Directory $dir does not exist in $REPO_DIR"
    fi
done

echo "Configuration directories have been moved to $DEST_DIR"

#!/bin/bash

# Move the RoxyGrub directory to /usr/share/grub/themes/
sudo mv RoxyGrub /usr/share/grub/themes/

# Define the new GRUB theme line
THEME_LINE='GRUB_THEME="/usr/share/grub/themes/RoxyGrub/theme.txt"'

# Uncomment and update existing GRUB_THEME line, or add it if not found
if grep -Eq '^\s*#?\s*GRUB_THEME=' /etc/default/grub; then
    sudo sed -i "s|^\s*#\?\s*GRUB_THEME=.*|$THEME_LINE|" /etc/default/grub
else
    echo "$THEME_LINE" | sudo tee -a /etc/default/grub > /dev/null
fi

# Generate new GRUB configuration
sudo grub-mkconfig -o /boot/grub/grub.cfg




# Define variables
THEME_DIR="RoxySDDM"
DEST_DIR="/usr/share/sddm/themes"
CONF_FILE="/usr/lib/sddm/sddm.conf.d/default.conf"

# Copy the theme directory using sudo
echo "Copying $THEME_DIR to $DEST_DIR..."
sudo cp -r "$THEME_DIR" "$DEST_DIR"

# Backup the original config file
echo "Backing up the original config file..."
sudo cp "$CONF_FILE" "$CONF_FILE.bak"

# Edit the config file to set Current=RoxySDDM under the [Theme] section
echo "Updating the configuration..."
sudo awk '
/^\[Theme\]/ {
  in_theme_section=1
  print
  next
}
/^\[/ {
  in_theme_section=0
  print
  next
}
in_theme_section && /^Current=/ {
  print "Current=RoxySDDM"
  next
}
{
  print
}
' "$CONF_FILE.bak" | sudo tee "$CONF_FILE" > /dev/null

echo "Done. Theme set to RoxySDDM."

