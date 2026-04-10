#!/bin/bash

set -euo pipefail

echo ""
echo "========================================"
echo "  Ubuntu Customization — Uninstall"
echo "========================================"
echo ""

if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Do not run as root."
    exit 1
fi

# Find the most recent backup
LATEST_BACKUP=$(ls -dt "$HOME"/.ubuntu_customization_backup_* 2>/dev/null | head -1)

echo "This will remove all customizations installed by setup.sh."
if [ -n "$LATEST_BACKUP" ]; then
    echo "A backup was found at: $LATEST_BACKUP"
fi
echo ""
read -rp "Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 0

# --- Kill conky ---
echo "Stopping Conky widgets..."
killall conky 2>/dev/null || true

# --- Remove conky autostart ---
echo "Removing Conky autostart entry..."
rm -f "$HOME/.config/autostart/conky_script_run.desktop"

# --- Disable and remove GNOME extensions ---
echo "Disabling GNOME extensions..."
gnome-extensions disable "dash-to-dock@micxgx.gmail.com" 2>/dev/null || true
gnome-extensions disable "user-theme@gnome-shell-extensions.gcampax.github.com" 2>/dev/null || true
gnome-extensions disable "apps-menu@gnome-shell-extensions.gcampax.github.com" 2>/dev/null || true

echo "Removing GNOME extension files..."
rm -rf "$HOME/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com"
rm -rf "$HOME/.local/share/gnome-shell/extensions/user-theme@gnome-shell-extensions.gcampax.github.com"
rm -rf "$HOME/.local/share/gnome-shell/extensions/apps-menu@gnome-shell-extensions.gcampax.github.com"

# --- Reset Dash-to-Dock dconf ---
echo "Resetting Dash-to-Dock settings..."
dconf reset -f /org/gnome/shell/extensions/dash-to-dock/ 2>/dev/null || true

# --- Remove installed themes ---
echo "Removing installed themes..."
rm -rf "$HOME/.themes/WhiteSur-dark"
# Orchis installs to ~/.themes/Orchis-Dark*
rm -rf "$HOME/.themes"/Orchis-Dark*

# --- Remove installed icons ---
echo "Removing installed icons..."
rm -rf "$HOME/.icons/Tela-nord-dark"

# --- Restore from backup if available ---
if [ -n "$LATEST_BACKUP" ]; then
    echo ""
    read -rp "Restore previous configs from backup? [y/N] " restore
    if [[ "$restore" =~ ^[Yy]$ ]]; then
        [ -d "$LATEST_BACKUP/themes_backup" ] && cp -r "$LATEST_BACKUP/themes_backup" "$HOME/.themes" && echo "  Restored ~/.themes"
        [ -d "$LATEST_BACKUP/icons_backup" ] && cp -r "$LATEST_BACKUP/icons_backup" "$HOME/.icons" && echo "  Restored ~/.icons"
        [ -d "$LATEST_BACKUP/fonts_backup" ] && cp -r "$LATEST_BACKUP/fonts_backup" "$HOME/.fonts" && echo "  Restored ~/.fonts"
        [ -f "$LATEST_BACKUP/locale_backup" ] && sudo cp "$LATEST_BACKUP/locale_backup" /etc/default/locale && echo "  Restored /etc/default/locale"
        if [ -f "$LATEST_BACKUP/dash_to_dock_dconf.dump" ]; then
            dconf load /org/gnome/shell/extensions/dash-to-dock/ < "$LATEST_BACKUP/dash_to_dock_dconf.dump" && echo "  Restored Dash-to-Dock dconf settings"
        fi
    fi
fi

# --- GRUB theme (requires sudo, ask separately) ---
echo ""
read -rp "Remove GRUB theme? (requires sudo) [y/N] " grub_confirm
if [[ "$grub_confirm" =~ ^[Yy]$ ]]; then
    echo "Removing GRUB theme..."
    sudo rm -rf /boot/grub/themes/Vimix 2>/dev/null || true
    sudo rm -rf /boot/grub2/themes/Vimix 2>/dev/null || true
    # Reset GRUB to default theme
    if [ -f /etc/default/grub ]; then
        sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
        sudo update-grub 2>/dev/null || sudo grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null || true
    fi
    echo "GRUB theme removed."
fi

echo ""
echo "Uninstall complete. Log out and back in for all changes to take effect."
