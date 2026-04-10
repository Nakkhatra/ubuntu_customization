# Ubuntu Desktop Customization

A one-click setup script that transforms your Ubuntu GNOME desktop with a dark-themed Dash-to-Dock, system monitoring widgets, custom themes, icons, fonts, and a GRUB boot screen theme.

## What This Installs

- **Dash-to-Dock** — Bottom-positioned dock with dark blue background, transparency, and smart behavior
- **GNOME Shell Extensions** — User Theme and Apps Menu
- **GTK Themes** — Orchis Dark Compact + WhiteSur Dark (with custom Ubuntu activities icon)
- **Icon Pack** — Tela Nord Dark
- **Conky Widgets** — 5 system monitoring widgets (CPU/GPU usage & temps, disk, memory, processes, date/time)
- **Antares Conky Theme** — Alternative widget theme with weather, ring gauges, and time in words (optional)
- **Custom Fonts** — Feather, Feena Casual, Laconic, Poiret One, Sweet Hipster
- **Wallpaper** — Minimalist nature forest/mountains
- **GRUB Theme** — Vimix dark boot screen

## Requirements

- **OS:** Ubuntu with GNOME desktop (tested on 20.04 LTS)
- **Display Server:** X11 recommended (Wayland has limited support)
- **Permissions:** Regular user account (the script uses `sudo` for package installation, locale, and GRUB)
- **Internet:** Required for downloading extensions and themes during setup

## Installation

```bash
git clone https://github.com/Nakkhatra/ubuntu_customization.git
cd ubuntu_customization
chmod +x setup.sh
./setup.sh
```

The script presents an interactive menu:

```
1) Install everything
2) Dash-to-Dock only
3) GNOME extensions only
4) Themes & icons only
5) Conky widgets only
6) Wallpaper only
7) GRUB theme only
8) Fonts only
0) Exit
```

For non-interactive full install: `./setup.sh --all`

## Conky Themes

During setup, you can choose between two Conky themes:

**Default Widgets** — 5 individual monitoring widgets positioned across the desktop:
- Usage & Temperature (CPU/GPU usage, temps for CPU, GPU, NVMe drives)
- Disk (root/home usage, I/O rate)
- Memory (RAM/SWAP usage)
- Processes (top 4 by CPU)
- Date/Time (decorative large format)

**Antares Theme** — An alternative all-in-one widget with:
- Weather display (requires free OpenWeatherMap API key)
- Ring gauge indicators for CPU, memory, disk
- Time displayed in words
- Customizable accent color via `conky_themes/Antares/change-color.sh`

Widget positions scale automatically based on your screen resolution.

## Dock Configuration

| Setting | Value |
|---------|-------|
| Position | Bottom |
| Background | #090f25 at 50% opacity |
| Icon Size | Dynamic, max 42px |
| Click Action | Minimize or show previews |
| Indicators | Dashes |
| Auto-hide | Enabled (dynamic) |

### Quick Tweaks

```bash
# Change dock position
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'LEFT'"

# Change background opacity
dconf write /org/gnome/shell/extensions/dash-to-dock/background-opacity 1.0

# Change icon size
dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size 64
```

## Uninstall

```bash
chmod +x uninstall.sh
./uninstall.sh
```

The uninstall script will:
- Stop Conky and remove autostart entry
- Disable and remove GNOME extensions
- Reset Dash-to-Dock settings
- Remove installed themes and icons
- Optionally restore your previous configs from backup
- Optionally remove the GRUB theme

## Backups

Every time `setup.sh` runs, it backs up your existing configs to `~/.ubuntu_customization_backup_<timestamp>/` before making changes. This includes your themes, icons, fonts, locale settings, Dash-to-Dock config, and Conky autostart entry.

## Troubleshooting

**Extensions don't appear after install:**
Log out and back in, or press Alt+F2 and type `r` (X11 only).

**Conky widgets positioned incorrectly:**
Widget positions auto-scale based on screen resolution. If positioning is off, the baseline is 1920x1080 — edit `gap_x`/`gap_y` values in the conky config files under `conky_themes/`.

**CPU temperature shows blank:**
The script auto-detects AMD (Tctl/Tdie) and Intel (Package id 0/Core 0) sensors. Ensure `lm-sensors` is running: `sudo sensors-detect` then `sensors` to verify.

**GPU rows not showing:**
GPU monitoring only appears when an NVIDIA GPU with `nvidia-smi` is detected. This is intentional — no "N/A" clutter on non-NVIDIA systems.

## License

This project is licensed under the MIT License.

The Dash-to-Dock extension is licensed under GPL v2+. The Antares Conky theme is licensed under GPL v3.

## Credits

- [Dash-to-Dock](https://github.com/micheleg/dash-to-dock) by Michele G
- [Orchis Theme](https://github.com/vinceliuice/Orchis-theme) by vinceliuice
- [Tela Icon Theme](https://github.com/vinceliuice/Tela-icon-theme) by vinceliuice
- [GRUB2 Themes](https://github.com/vinceliuice/grub2-themes) by vinceliuice
- [Antares Conky](https://www.pling.com/p/1462012/) by Closebox73
- GNOME Project and Ubuntu Team
