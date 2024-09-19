#!/bin/bash

# Define a list of packages and extensions to install
PACKAGES="gnome-tweaks gettext conky-all lua5.3 unzip"




# Update and install all packages in one line
echo "Updating package list and installing required packages..."
sudo apt update && sudo apt upgrade && sudo apt install -y $PACKAGES



# Dash to Dock
./setup_dash_to_dock




# Define an array of extension names
extensions=("user-theme" "apps-menu")

# Function to install and enable an extension
install_extension() {
    local ext_name="$1@gnome-shell-extensions.gcampax.github.com"
    local ext_dir="extensions/$1"

    echo "Installing extension: $ext_name"
    
    # Create the directory for the extension
    mkdir -p ~/.local/share/gnome-shell/extensions/${ext_name}/
    
    # Copy the extension files
    cp -r ${ext_dir}/* ~/.local/share/gnome-shell/extensions/${ext_name}/
    
    # Reload GNOME Shell
    echo "Reloading GNOME Shell..."
    gnome-shell --replace &
    sleep 5  # Wait for GNOME Shell to reload

    echo "Enabling extension: $ext_name"
    # Enable the extension
    gnome-extensions enable ${ext_name}         # ${ext_name} the variable is mentioned this way when it is a string containing complex characters like directory name containing '/' or etc
}

# Clone the repository
echo "Cloning GNOME Shell Extensions repository..."
git clone https://gitlab.gnome.org/GNOME/gnome-shell-extensions.git
cd gnome-shell-extensions

# Install and enable each extension
for ext_name in "${extensions[@]}"; do
    install_extension "$ext_name"
done

# Navigate back to the main directory
cd ..


# Install orchis dark compact theme
git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme
./install.sh --color dark
cd ..
# Clean up
rm -rf Orchis-theme 




# Install shell theme whitesur-dark. Provided the theme as I replaced the activities icon with ubuntu activites.svg
mkdir -p $HOME/.themes
unzip -o themes/WhiteSur-dark-linux-activity.zip -d $HOME/.themes/




# Install icons (Tela nord dark)
mkdir -p $HOME/.icons
unzip -o icons/Tela-nord-dark.zip -d $HOME/.icons/




# Install fonts for conky
mkdir -p $HOME/.fonts
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
mkdir -p $HOME/.config/autostart
DESKTOP_FILE="$HOME/.config/autostart/conky_script_run.desktop"

# Copy the .desktop file to the autostart directory
cp conky_script_run.desktop "$DESKTOP_FILE"

# Modify the .desktop file to replace the placeholder with the current directory
sed -i "s|Exec=scripts.sh|Exec=$CURRENT_DIR/scripts.sh|g" "$DESKTOP_FILE"

# Make the desktop file executable
chmod +x ~/.config/autostart/conky_script_run.desktop








