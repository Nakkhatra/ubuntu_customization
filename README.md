# Ubuntu 20.04 Desktop Customization Script

A one-click solution for customizing Ubuntu 20.04 with a sleek, dark-themed Dash-to-Dock setup.

## 🚀 Quick Start

```bash
# Clone or download the script
wget https://your-repo-url/dash-to-dock-setup.sh

# Make executable and run
chmod +x dash-to-dock-setup.sh
./dash-to-dock-setup.sh
```

## 📋 What This Script Does

This script transforms your default Ubuntu 20.04 desktop by:

✅ Installs Dash-to-Dock - Modern dock replacement for Ubuntu default sidebar
✅ Applies Dark Theme - Beautiful dark blue (#090f25) background with transparency
✅ Optimizes Layout - Bottom-positioned dock with smart sizing and behavior
✅ Configures Behavior - Sets up click actions, indicators, and animations
✅ Single Command Setup - Everything configured automatically

## 🎨 Preview

Before: Default Ubuntu 20.04 with left sidebar After: Sleek bottom dock with dark theme and transparency

### Key Visual Features

🌙 Dark Theme: Deep blue background with 50% transparency
📍 Bottom Dock: Clean bottom positioning like macOS
🔍 Smart Previews: Click to minimize or show window previews
⚡ Dynamic Sizing: Icons adapt based on content
🎯 Running Indicators: Dash-style indicators for active apps

## 🛠️ Requirements

- OS: Ubuntu 20.04 LTS (GNOME Desktop)
- Dependencies: Git, Make, dconf (usually pre-installed)
- Permissions: User-level installation (no sudo required)

## 📦 Installation

### Method 1: Direct Download & Run

```bash
wget https://raw.githubusercontent.com/your-username/your-repo/main/dash-to-dock-setup.sh
chmod +x dash-to-dock-setup.sh
./dash-to-dock-setup.sh
```

### Method 2: Clone Repository

```bash
git clone https://github.com/your-username/ubuntu-customization.git
cd ubuntu-customization
chmod +x dash-to-dock-setup.sh
./dash-to-dock-setup.sh
```

### Method 3: One-liner

```bash
curl -sSL https://raw.githubusercontent.com/your-username/your-repo/main/dash-to-dock-setup.sh | bash
```

## ⚙️ Configuration Details

| Feature | Setting | Value |
|---------|---------|-------|
| Position | Bottom dock | BOTTOM |
| Background | Dark blue with transparency | #090f25 @ 50% |
| Icon Size | Dynamic, max 42px | 42px |
| Click Action | Minimize or show previews | Smart behavior |
| Indicators | Dash style for running apps | DASHES |
| Auto-hide | Dynamic show/hide | Enabled |

## 🔧 Customization

### Quick Tweaks

Change dock position to left:

```bash
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'LEFT'"
```

Make background fully opaque:

```bash
dconf write /org/gnome/shell/extensions/dash-to-dock/background-opacity 1.0
```

Increase icon size:

```bash
dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size 64
```

### Full Reset

```bash
dconf reset -f /org/gnome/shell/extensions/dash-to-dock/
```

## 🐛 Troubleshooting

### Extension does not appear after installation

```bash
# Restart GNOME Shell
Alt + F2 → type 'r' → Enter
# Or logout/login
```

### Build errors during installation

```bash
# Install build dependencies
sudo apt update
sudo apt install make gettext git
```

### Settings not applied

```bash
# Check if dconf is working
dconf list /org/gnome/shell/extensions/dash-to-dock/

# Force restart desktop session
sudo systemctl restart gdm3
```

### Extension shows but does not work

```bash
# Check GNOME Shell version compatibility
gnome-shell --version

# Reinstall extension
rm -rf ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com
./dash-to-dock-setup.sh
```

## 🗑️ Uninstallation

### Quick Removal

```bash
# Disable extension
gnome-extensions disable dash-to-dock@micxgx.gmail.com

# Remove files
rm -rf ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com

# Reset settings (optional)
dconf reset -f /org/gnome/shell/extensions/dash-to-dock/
```

### Complete Cleanup

```bash
# Remove all traces
rm -rf ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com
rm -rf ~/dash-to-dock
dconf reset -f /org/gnome/shell/extensions/dash-to-dock/
```

## 🤝 Contributing

Found a bug or want to improve the script? Contributions welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add some improvement'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

The Dash-to-Dock extension itself is licensed under GPL v2+.

## 🙏 Credits

- Dash-to-Dock by Michele G - The amazing GNOME extension
- Ubuntu Team - For the solid foundation
- GNOME Project - For the desktop environment

## 📊 Compatibility

| Ubuntu Version | Status | Notes |
|----------------|--------|-------|
| 20.04 LTS | ✅ Tested | Primary target |
| 18.04 LTS | ⚠️ Partial | May work with older GNOME |
| 22.04 LTS | 🔄 Testing | Should work, testing in progress |

## 🆘 Support

- Issues: GitHub Issues
- Discussions: GitHub Discussions
- Ubuntu Forums: Ask Ubuntu

⭐ If this script helped you, please star the repository!

Made with ❤️ for the Ubuntu community
