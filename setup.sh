#!/bin/bash

set -e

# Define a list of packages and extensions to install
PACKAGES="gnome-tweaks gettext conky-all lua5.3 unzip make build-essential nodejs npm sass lm-sensors"



# Update and install all packages in one line
echo "Updating package list and installing required packages..."
sudo apt update && sudo apt upgrade -y && sudo apt install -y $PACKAGES



# Dash to Dock
chmod +x setup_dash_to_dock.sh
./setup_dash_to_dock.sh




# Define an array of extension names
extensions=("user-theme" "apps-menu")

# Function to copy extension files (no GNOME Shell restart per extension)
install_extension() {
    local ext_name="$1@gnome-shell-extensions.gcampax.github.com"
    local ext_dir="extensions/$1"

    echo "Installing gnome shell extension: $ext_name"

    # Create the directory for the extension
    mkdir -p ~/.local/share/gnome-shell/extensions/${ext_name}/

    # Copy the extension files
    cp -r ${ext_dir}/* ~/.local/share/gnome-shell/extensions/${ext_name}/
}

# Function to enable an extension (called after GNOME Shell is reloaded)
enable_extension() {
    local ext_name="$1@gnome-shell-extensions.gcampax.github.com"
    echo "Enabling extension: $ext_name"
    gnome-extensions enable ${ext_name}
}

# Clone the repository
echo "Cloning GNOME Shell Extensions repository..."
git clone https://gitlab.gnome.org/GNOME/gnome-shell-extensions.git
cd gnome-shell-extensions

# Copy all extension files first
for ext_name in "${extensions[@]}"; do
    install_extension "$ext_name"
done

# Navigate back to the main directory and clean up
cd ..
rm -rf gnome-shell-extensions

# Reload GNOME Shell once after all extensions are copied
echo "Reloading GNOME Shell..."
gnome-shell --replace &
sleep 5  # Wait for GNOME Shell to reload

# Enable all extensions
for ext_name in "${extensions[@]}"; do
    enable_extension "$ext_name"
done


# Install orchis dark compact theme
echo "Installing orchis dark compact. . ."
git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme
./install.sh --color dark
cd ..
# Clean up
rm -rf Orchis-theme




# Install shell theme whitesur-dark. Provided the theme as I replaced the activities icon with ubuntu activites.svg
echo "Installing whitesurrchis dark custom. . ."
mkdir -p $HOME/.themes
unzip -o themes/WhiteSur-dark-linux-activity.zip -d $HOME/.themes/ >/dev/null




# Install icons (Tela nord dark)
echo "Installing icons. . . ."
mkdir -p $HOME/.icons
unzip -o icons/Tela-nord-dark.zip -d $HOME/.icons/ >/dev/null




# Install fonts for conky
echo "Installing fonts. . . ."
mkdir -p $HOME/.fonts
cp -r fonts/* $HOME/.fonts/ >/dev/null




echo "Converting time and language to English first for the fonts to work properly. . . ."
sudo sed -i -e 's/^LANG=.*/LANG=en_US.UTF-8/' \
            -e 's/^LC_TIME=.*/LC_TIME=en_US.UTF-8/' \
            /etc/default/locale




# Store the project root before changing directories
PROJECT_ROOT=$(pwd)

echo "Setup conky script to start on startup. . . ."
cd conky_themes

# Get the current directory
CURRENT_DIR=$(pwd)

# Path to the .desktop file
mkdir -p $HOME/.config/autostart
DESKTOP_FILE="$HOME/.config/autostart/conky_script_run.desktop"

# Copy the .desktop file to the autostart directory
cp conky_script_run.desktop "$DESKTOP_FILE"

# Modify the .desktop file to replace the placeholder with the current directory
sed -i "s|Exec=scripts.sh|Exec=$CURRENT_DIR/scripts.sh|g" "$DESKTOP_FILE"

# Fix the lua_load path in cool_date to use the absolute path of this directory
sed -i "s|lua_load = '.*day_format.lua'|lua_load = '$CURRENT_DIR/day_format.lua'|g" cool_date

# Make the desktop file executable
chmod +x ~/.config/autostart/conky_script_run.desktop

cd ..

echo "Updating wallpaper. . . ."
gsettings set org.gnome.desktop.background picture-uri "file://$PROJECT_ROOT/wallpapers/minimalist-nature-forest-mountains-digital-art-uhdpaper.com-hd-36.jpg"

# Update grub theme
git clone https://github.com/vinceliuice/grub2-themes.git
sudo grub2-themes/install.sh -t vimix -c 1920x1080 -i white
rm -rf grub2-themes
