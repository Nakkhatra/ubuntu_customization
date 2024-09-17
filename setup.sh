#!/bin/bash

# Define a list of packages and extensions to install
PACKAGES="gnome-tweaks gnome-shell-extension-dash-to-dock conky-all lua5.3 gnome-shell-extension-apps-menu gnome-shell-extension-user-theme"

# Update and install all packages in one line
echo "Updating package list and installing required packages..."
sudo apt update && sudo apt upgrade && sudo apt install -y $PACKAGES

# Enabling extensions
echo "Enabling GNOME extensions..."
# Applications Menu
gnome-extensions enable apps-menu@gnome-shell-extensions.gcampax.github.com
# Dash to Dock
gnome-extensions enable dash-to-dock@micxgx.gmail.com
# User Themes
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com


# Install orchis dark compact theme
git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme
./install.sh --color dark
cd .. 


# Install shell theme whitesur-dark. Provided the theme as I replaced the activities icon with ubuntu activites.svg
unzip WhiteSur-dark-linux-activity.zip $HOME/.themes/
# Install icons (Tela nord dark)
unzip Tela-nord-dark.zip $HOME/.icons/
# Install fonts for conky
cp -r fonts/* $HOME/.fonts/

# Convert time and language to English first for the fonts to work properly
sudo sed -i -e 's/^LANG=.*/LANG=en_US.UTF-8/' \
            -e 's/^LC_TIME=.*/LC_TIME=en_US.UTF-8/' \
            /etc/default/locale

# Setup conky script to start on startup
cd conky_themes
# Get the current directory
CURRENT_DIR=$(pwd)
# Path to the .desktop file
DESKTOP_FILE="$HOME/.config/autostart/conky_script_run.desktop"
# Copy the .desktop file to the autostart directory
cp conky_script_run.desktop "$DESKTOP_FILE"
# Modify the .desktop file to replace the placeholder with the current directory
sed -i "s|Exec=scripts.sh|Exec=$CURRENT_DIR/scripts.sh|g" "$DESKTOP_FILE"
# Make the desktop file executable
chmod +x ~/.config/autostart/conky_script_run.desktop








