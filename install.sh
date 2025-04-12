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

sudo pacman -S ttf-inconsolata-g
sudo pacman -S ttf-jetbrains-mono-nerd
yay -S --noconfirm fastfetch kitty rofi vesktop waybar-cava nm-applet hyprpaper mpvpaper hyprpolkit hyprlock hyprshot teams-for-linux

#Waterfox from source because yay version is cooked

set -e

# Define some variables
INSTALL_DIR="$HOME/waterfox"
BUILD_DIR="$INSTALL_DIR/waterfox-build"
SYMLINK_DIR="/usr/local/bin"
WATERFOX_BIN="$BUILD_DIR/obj-x86_64-pc-linux-gnu/dist/bin/waterfox"

echo ">>> Installing dependencies..."
sudo apt update
sudo apt install -y git autoconf2.13 build-essential \
  python3 python3-pip clang llvm libgtk-3-dev \
  libdbus-glib-1-dev libxt-dev libx11-xcb-dev \
  libgconf2-dev libasound2-dev yasm \
  libpulse-dev libvpx-dev libxrandr-dev \
  libxss-dev libnss3-dev libnspr4-dev unzip zip

echo ">>> Cloning Waterfox source..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"
git clone https://github.com/WaterfoxCo/Waterfox.git waterfox-source

cd waterfox-source

echo ">>> Setting up build environment..."
cat > mozconfig <<EOF
ac_add_options --enable-application=browser
mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/../obj-x86_64-pc-linux-gnu
ac_add_options --enable-optimize
ac_add_options --enable-release
ac_add_options --disable-debug
EOF

echo ">>> Starting build (this may take a while)..."
./mach bootstrap --no-interactive
./mach build

echo ">>> Build complete."

# Optionally, install the binary in a known location
echo ">>> Creating symlink to 'waterfox'..."
sudo ln -sf "$WATERFOX_BIN" "$SYMLINK_DIR/waterfox"

echo ">>> Done! You can now run Waterfox using the command: waterfox"


echo "Waterfox installation complete!"


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

