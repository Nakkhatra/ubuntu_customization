#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR=""

on_error() {
    echo ""
    echo "ERROR: Setup failed at line $1 (exit code $2)."
    echo "Partial installation may have occurred."
    if [ -n "${BACKUP_DIR}" ] && [ -d "${BACKUP_DIR}" ]; then
        echo "Your original configs were backed up to: $BACKUP_DIR"
    fi
}
trap 'on_error $LINENO $?' ERR

# ============================================================
# Pre-flight checks
# ============================================================
preflight_checks() {
    if [ "$(id -u)" -eq 0 ]; then
        echo "ERROR: Do not run this script as root. It uses sudo where needed."
        exit 1
    fi

    if ! command -v git &>/dev/null; then
        echo "ERROR: git is required but not installed. Run: sudo apt install git"
        exit 1
    fi

    if [[ "${XDG_CURRENT_DESKTOP:-}" != *"GNOME"* ]]; then
        echo "WARNING: This script is designed for GNOME desktop (detected: ${XDG_CURRENT_DESKTOP:-unknown})."
        read -rp "Continue anyway? [y/N] " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
    fi

    if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
        echo "WARNING: Wayland detected. Some features (conky, GNOME shell restart) may not work correctly."
        echo "X11 is recommended for full compatibility."
        read -rp "Continue anyway? [y/N] " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
    fi
}

# ============================================================
# Backup existing configs
# ============================================================
backup_configs() {
    BACKUP_DIR="$HOME/.ubuntu_customization_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    echo "Backing up existing configs to $BACKUP_DIR ..."
    [ -d "$HOME/.themes" ] && cp -r "$HOME/.themes" "$BACKUP_DIR/themes_backup" 2>/dev/null || true
    [ -d "$HOME/.icons" ] && cp -r "$HOME/.icons" "$BACKUP_DIR/icons_backup" 2>/dev/null || true
    [ -d "$HOME/.fonts" ] && cp -r "$HOME/.fonts" "$BACKUP_DIR/fonts_backup" 2>/dev/null || true
    [ -f /etc/default/locale ] && sudo cp /etc/default/locale "$BACKUP_DIR/locale_backup" 2>/dev/null || true
    dconf dump /org/gnome/shell/extensions/dash-to-dock/ > "$BACKUP_DIR/dash_to_dock_dconf.dump" 2>/dev/null || true
    [ -f "$HOME/.config/autostart/conky_script_run.desktop" ] && cp "$HOME/.config/autostart/conky_script_run.desktop" "$BACKUP_DIR/" 2>/dev/null || true
    echo "Backup complete."
}

# ============================================================
# Install system packages
# ============================================================
install_packages() {
    local packages="gnome-tweaks gettext conky-all lua5.3 unzip make build-essential nodejs npm sass lm-sensors"

    echo "Updating package list and installing required packages..."
    sudo apt update
    # shellcheck disable=SC2086 -- intentional word splitting for package list
    sudo apt install -y $packages
}

# ============================================================
# Dash to Dock
# ============================================================
install_dash_to_dock() {
    echo "Installing Dash to Dock..."
    chmod +x "$PROJECT_ROOT/setup_dash_to_dock.sh"
    "$PROJECT_ROOT/setup_dash_to_dock.sh"
}

# ============================================================
# GNOME Shell extensions (user-theme, apps-menu)
# ============================================================
install_extensions() {
    local extensions=("user-theme" "apps-menu")

    install_extension() {
        local ext_name="$1@gnome-shell-extensions.gcampax.github.com"
        local ext_dir="extensions/$1"

        echo "Installing gnome shell extension: $ext_name"
        mkdir -p "$HOME/.local/share/gnome-shell/extensions/${ext_name}/"
        cp -r "${ext_dir}"/* "$HOME/.local/share/gnome-shell/extensions/${ext_name}/"
    }

    enable_extension() {
        local ext_name="$1@gnome-shell-extensions.gcampax.github.com"
        echo "Enabling extension: $ext_name"
        gnome-extensions enable "${ext_name}"
    }

    echo "Cloning GNOME Shell Extensions repository..."
    rm -rf "$PROJECT_ROOT/gnome-shell-extensions"
    git clone https://gitlab.gnome.org/GNOME/gnome-shell-extensions.git
    cd gnome-shell-extensions

    for ext_name in "${extensions[@]}"; do
        install_extension "$ext_name"
    done

    cd "$PROJECT_ROOT"
    rm -rf gnome-shell-extensions

    # Reload GNOME Shell
    echo "Reloading GNOME Shell..."
    if [ "${XDG_SESSION_TYPE:-}" = "x11" ]; then
        busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting...")' &>/dev/null || gnome-shell --replace &
        sleep 3
    else
        echo "Wayland session detected — please log out and back in to activate extensions."
    fi

    for ext_name in "${extensions[@]}"; do
        enable_extension "$ext_name"
    done
}

# ============================================================
# Themes (Orchis Dark + WhiteSur Dark)
# ============================================================
install_themes() {
    echo "Installing Orchis dark compact theme..."
    rm -rf "$PROJECT_ROOT/Orchis-theme"
    git clone https://github.com/vinceliuice/Orchis-theme.git
    cd Orchis-theme
    ./install.sh --color dark
    cd "$PROJECT_ROOT"
    rm -rf Orchis-theme

    echo "Installing WhiteSur dark custom theme..."
    mkdir -p "$HOME/.themes"
    unzip -o "$PROJECT_ROOT/themes/WhiteSur-dark-linux-activity.zip" -d "$HOME/.themes/" >/dev/null
}

# ============================================================
# Icons (Tela Nord Dark)
# ============================================================
install_icons() {
    echo "Installing Tela Nord Dark icons..."
    mkdir -p "$HOME/.icons"
    unzip -o "$PROJECT_ROOT/icons/Tela-nord-dark.zip" -d "$HOME/.icons/" >/dev/null
}

# ============================================================
# Fonts
# ============================================================
install_fonts() {
    echo "Installing fonts..."
    mkdir -p "$HOME/.fonts"
    cp -r "$PROJECT_ROOT/fonts"/* "$HOME/.fonts/" >/dev/null

    echo "Setting locale to English (UTF-8) for fonts to work properly..."
    sudo sed -i -e 's/^LANG=.*/LANG=en_US.UTF-8/' \
                -e 's/^LC_TIME=.*/LC_TIME=en_US.UTF-8/' \
                /etc/default/locale
}

# ============================================================
# Conky widgets
# ============================================================
setup_conky() {
    local conky_dir="$PROJECT_ROOT/conky_themes"
    local conky_theme="${1:-}"

    # If not passed as argument, ask the user
    if [ -z "$conky_theme" ]; then
        echo ""
        echo "Choose a Conky theme:"
        echo "  1) Default widgets (CPU, GPU, disk, memory, processes, date)"
        echo "  2) Antares theme (weather, ring gauges, time in words)"
        read -rp "Select [1]: " theme_choice
        theme_choice="${theme_choice:-1}"
    else
        theme_choice="$conky_theme"
    fi

    mkdir -p "$HOME/.config/autostart"
    local desktop_file="$HOME/.config/autostart/conky_script_run.desktop"

    case "$theme_choice" in
        1|default)
            echo "Setting up default Conky widgets..."
            local exec_cmd="$conky_dir/scripts.sh"

            # Fix the lua_load path in cool_date
            sed -i "s|lua_load = '.*day_format.lua'|lua_load = '$conky_dir/day_format.lua'|g" "$conky_dir/cool_date"

            chmod +x "$conky_dir/scripts.sh"
            ;;
        2|antares)
            echo "Setting up Antares Conky theme..."
            local antares_dir="$conky_dir/Antares"
            local exec_cmd="$antares_dir/start.sh"

            # Install Antares fonts
            mkdir -p "$HOME/.fonts"
            cp -r "$antares_dir/fonts"/* "$HOME/.fonts/" 2>/dev/null || true

            # Handle weather config
            if [ ! -f "$antares_dir/scripts/weather.conf" ]; then
                echo ""
                echo "Antares supports weather display via OpenWeatherMap API."
                read -rp "Set up weather? (requires free API key from openweathermap.org) [y/N] " setup_weather
                if [[ "$setup_weather" =~ ^[Yy]$ ]]; then
                    read -rp "Enter your OpenWeatherMap API key: " api_key
                    read -rp "Enter your city ID (find at openweathermap.org/city): " city_id
                    cat > "$antares_dir/scripts/weather.conf" <<WEOF
city_id=$city_id
api_key=$api_key
unit=metric
lang=en
WEOF
                    echo "Weather config saved."
                else
                    echo "Skipping weather setup. You can configure it later by copying:"
                    echo "  $antares_dir/scripts/weather.conf.example -> weather.conf"
                fi
            fi

            chmod +x "$antares_dir/start.sh"
            ;;
        *)
            echo "Invalid choice. Using default widgets."
            local exec_cmd="$conky_dir/scripts.sh"
            sed -i "s|lua_load = '.*day_format.lua'|lua_load = '$conky_dir/day_format.lua'|g" "$conky_dir/cool_date"
            chmod +x "$conky_dir/scripts.sh"
            ;;
    esac

    cat > "$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Exec=$exec_cmd
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Conky Widgets
Comment=Start Conky system monitoring widgets at login
EOF

    chmod +x "$desktop_file"
}

# ============================================================
# Wallpaper
# ============================================================
set_wallpaper() {
    echo "Updating wallpaper..."
    local wallpaper_path="file://$PROJECT_ROOT/wallpapers/minimalist-nature-forest-mountains-digital-art-uhdpaper.com-hd-36.jpg"
    gsettings set org.gnome.desktop.background picture-uri "$wallpaper_path"
    # Also set dark mode wallpaper (GNOME 42+)
    gsettings set org.gnome.desktop.background picture-uri-dark "$wallpaper_path" 2>/dev/null || true
}

# ============================================================
# GRUB theme
# ============================================================
install_grub_theme() {
    echo "Installing GRUB theme..."
    rm -rf "$PROJECT_ROOT/grub2-themes"
    git clone https://github.com/vinceliuice/grub2-themes.git
    sudo grub2-themes/install.sh -t vimix -c 1920x1080 -i white
    rm -rf grub2-themes
}

# ============================================================
# Run all components
# ============================================================
install_all() {
    install_packages
    install_dash_to_dock
    install_extensions
    install_themes
    install_icons
    install_fonts
    setup_conky
    set_wallpaper
    install_grub_theme
}

# ============================================================
# Interactive menu
# ============================================================
show_menu() {
    echo ""
    echo "========================================"
    echo "  Ubuntu Desktop Customization Setup"
    echo "========================================"
    echo ""
    echo "  1) Install everything"
    echo "  2) Dash-to-Dock only"
    echo "  3) GNOME extensions only"
    echo "  4) Themes & icons only"
    echo "  5) Conky widgets only"
    echo "  6) Wallpaper only"
    echo "  7) GRUB theme only"
    echo "  8) Fonts only"
    echo "  0) Exit"
    echo ""
    read -rp "Select an option [1]: " choice
    choice="${choice:-1}"

    case "$choice" in
        1)
            install_all
            ;;
        2)
            install_packages
            install_dash_to_dock
            ;;
        3)
            install_packages
            install_extensions
            ;;
        4)
            install_packages
            install_themes
            install_icons
            ;;
        5)
            install_packages
            install_fonts
            setup_conky
            ;;
        6)
            set_wallpaper
            ;;
        7)
            install_grub_theme
            ;;
        8)
            install_fonts
            ;;
        0)
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid option: $choice"
            exit 1
            ;;
    esac
}

# ============================================================
# Main
# ============================================================
preflight_checks
backup_configs

if [ "${1:-}" = "--all" ]; then
    install_all
else
    show_menu
fi

echo ""
echo "Setup complete!"
echo "Backup of previous configs: $BACKUP_DIR"
echo "You may need to log out and back in for all changes to take effect."
