# NixOS Shell Switcher

A seamless desktop shell switcher for NixOS with Hyprland, featuring dynamic Stylix theming and a clean Rofi interface.

![Shell Switcher Demo](https://img.shields.io/badge/NixOS-25.05-blue?logo=nixos)
![License](https://img.shields.io/badge/license-MIT-green)

## 🎯 Overview

The NixOS Shell Switcher allows you to instantly switch between different desktop shells on Hyprland without logging out or restarting your session. It features:

- ⚡ **Instant Switching** - Change shells in real-time with no restart needed
- 🎨 **Stylix Integration** - Dynamically themed UI matching your system colors
- 🎯 **Smart Detection** - Automatically detects and marks your current active shell
- ⌨️ **Hotkey Support** - Quick access via `SUPER+ALT+S`
- 🔄 **Process Management** - Clean shell cleanup and activation

## 🖥️ Supported Shells

- **DankMaterialShell** - Material design desktop shell
- **Noctalia Shell** - Dark-themed elegant shell
- **Caelestia Shell** - Celestial-inspired shell
- **Waybar** - Default Wayland bar (fallback)

## 📦 Installation

### Prerequisites

- NixOS 25.05 (or compatible)
- Hyprland window manager
- Home Manager (for declarative config management)
- Stylix (for dynamic theming) - *Optional but recommended*

### Quick Start

1. **Clone into your NixOS configuration:**

```bash
# Clone this repository
git clone https://github.com/Lenno-skill/NixOs-Shell-Switcher.git

# Or add as a flake input in your flake.nix:
inputs.shell-switcher.url = "github:Lenno-skill/NixOs-Shell-Switcher";
```

2. **Copy the required files to your NixOS configuration:**

```bash
# Copy script module
cp modules/home/scripts/shellswitcher.nix /path/to/your/config/modules/home/scripts/

# Copy Rofi configurations
cp modules/home/rofi/shellswitcher.rasi /path/to/your/config/modules/home/rofi/
cp modules/home/rofi/themes/shellswitcher.rasi /path/to/your/config/modules/home/rofi/themes/

# Copy Hyprland integration files
cp modules/home/hyprland/*-integration.conf /path/to/your/config/modules/home/hyprland/
```

3. **Update your NixOS configuration:**

**In `modules/home/scripts/default.nix`:**
```nix
{pkgs, config, ...}: {
  home.packages = with pkgs; [
    (import ./shellswitcher.nix { inherit pkgs config; })
    # ... other scripts
  ];
}
```

**In `modules/home/default.nix`:**
```nix
{
  # ... existing configuration

  # Link Rofi config files
  home.file.".config/rofi/shellswitcher.rasi" = {
    source = ./rofi/shellswitcher.rasi;
    force = true;
  };
  
  home.file.".config/rofi/themes/shellswitcher.rasi" = {
    source = ./rofi/themes/shellswitcher.rasi;
    force = true;
  };

  # Link Hyprland integration files
  home.file.".config/hypr/dms-integration.conf".source = ./hyprland/dms-integration.conf;
  home.file.".config/hypr/noctalia-integration.conf".source = ./hyprland/noctalia-integration.conf;
  home.file.".config/hypr/caelestia-integration.conf".source = ./hyprland/caelestia-integration.conf;
}
```

**In `modules/home/hyprland/binds.nix`:**
```nix
{
  wayland.windowManager.hyprland.settings = {
    bind = [
      # ... existing binds
      "$modifier ALT,S,exec,shellswitcher"
    ];
  };
}
```

4. **Rebuild your NixOS configuration:**

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

## 🎨 Stylix Theming

The shell switcher automatically integrates with your Stylix theme. Colors are dynamically pulled from your current Stylix configuration using the base16 color scheme:

- **Background**: `base00` - Main background color
- **Foreground/Text**: `base05` - Primary text color
- **Accent/Border**: `base0D` - Accent color for highlights
- **Selection**: `base02` - Selected item background
- **Muted Elements**: `base03` - Secondary UI elements

### Manual Theme Customization

If you don't use Stylix or want to customize colors, edit `modules/home/rofi/themes/shellswitcher.rasi` and replace the Stylix color variables with your preferred colors.

## 🔧 Usage

### Via Hotkey
Press `SUPER+ALT+S` to open the shell switcher menu.

### Via Terminal
```bash
shellswitcher
```

### Shell Selection
1. The current active shell is marked with a ● indicator
2. Use arrow keys or type to filter shells
3. Press Enter to switch to the selected shell
4. The previous shell processes are automatically terminated
5. Hyprland configuration is updated and reloaded

## 📁 File Structure

```
modules/home/
├── scripts/
│   ├── shellswitcher.nix              # Main shell switcher script
│   ├── SHELLSWITCHER-README.md        # Technical documentation
│   └── default.nix                     # Scripts module index
├── rofi/
│   ├── shellswitcher.rasi              # Rofi launcher config
│   └── themes/
│       └── shellswitcher.rasi          # Rofi visual theme (Stylix)
└── hyprland/
    ├── binds.nix                       # Keybinding configuration
    ├── dms-integration.conf            # DankMaterialShell config
    ├── noctalia-integration.conf       # Noctalia Shell config
    └── caelestia-integration.conf      # Caelestia Shell config

Documentation:
├── README-SHELLSWITCHER.md             # This file (GitHub README)
└── SHELL-SWITCHER.md                   # User guide (German)
```

## 🛠️ Architecture

### Shell Detection System
The switcher uses a two-tier detection system:

1. **Process-based detection (Primary)**: Checks for running shell processes using `pgrep`
2. **Config-based detection (Fallback)**: Parses `hyprland.conf` to find active shell integration

### Switching Process
1. **Detection**: Identify currently active shell
2. **Menu Display**: Show Rofi menu with active shell marked
3. **User Selection**: Wait for user to select new shell
4. **Cleanup**: Terminate all running shell processes
5. **Config Update**: Modify `hyprland.conf` to source new shell integration
6. **Activation**: Start the selected shell process
7. **Reload**: Trigger Hyprland configuration reload

### File Management
- **Backup System**: Creates `.shellswitcher.bak` backup before config changes
- **Atomic Updates**: Uses `sed` for safe config file modifications
- **Force Linking**: Home Manager `force = true` prevents file conflicts

## 🔄 Adding New Shells

To add a custom shell to the switcher:

1. **Create Hyprland Integration File**

Create `modules/home/hyprland/myshell-integration.conf`:
```conf
# MyShell Integration
exec-once = myshell-start
# ... other shell-specific settings
```

2. **Update shellswitcher.nix**

Add your shell to the arrays:
```bash
declare -A SHELLS=(
  # ... existing shells
  ["MyShell"]="myshell-integration.conf"
)

declare -A SHELL_COMMANDS=(
  # ... existing commands
  ["MyShell"]="myshell-start"
)
```

Add detection logic:
```bash
get_current_shell() {
  if ${pkgs.procps}/bin/pgrep -f "myshell-start" > /dev/null 2>&1; then
    echo "MyShell"
  elif ...
  # ... existing detection
}
```

Add switch case:
```bash
case "$SELECTION" in
  # ... existing cases
  "MyShell")
    ${pkgs.gnused}/bin/sed -i 's|^#source = ~/.config/hypr/myshell-integration.conf|source = ~/.config/hypr/myshell-integration.conf|g' "$HYPR_CONFIG"
    myshell-start &
    ;;
esac
```

3. **Link Integration File**

In `modules/home/default.nix`:
```nix
home.file.".config/hypr/myshell-integration.conf".source = ./hyprland/myshell-integration.conf;
```

4. **Rebuild Configuration**
```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

## 📋 Dependencies

The shell switcher automatically includes all required dependencies:

- `rofi-wayland` - Menu interface
- `procps` - Process management (pgrep, pkill)
- `gnused` - Config file editing
- `libnotify` - Desktop notifications
- `hyprland` - Hyprland reload command

These are declared in the Nix expression and don't need manual installation.

## 🐛 Troubleshooting

### Shell doesn't switch
- Verify the shell integration file exists in `~/.config/hypr/`
- Check if the shell command is in your PATH
- Review Hyprland logs: `journalctl --user -u hyprland`

### Rofi theme not applied
- Ensure Rofi config files are linked: `ls -la ~/.config/rofi/`
- Check if Stylix is enabled in your configuration
- Force rebuild: `sudo nixos-rebuild switch --flake .#your-hostname --recreate-lock-file`

### Home Manager conflicts
- If you see "existing file" errors, add `force = true` to file declarations
- Backup existing configs before first installation
- Use the activation script pattern from `hyprland.nix`

### Active shell not detected
- The switcher first checks running processes, then falls back to config file
- Manually verify: `pgrep -af "shell-name"`
- Check if `hyprland.conf` has the correct source line uncommented

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Report bugs and issues
- Suggest new shells to support
- Improve documentation
- Submit pull requests

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Inspired by the [bgselector](https://github.com/your-repo/bgselector) tool
- Built for the [Black Don OS](https://github.com/Lenno-skill/black-don-os) NixOS distribution
- Uses [Stylix](https://github.com/danth/stylix) for dynamic theming
- Powered by [Hyprland](https://hyprland.org)

## 📞 Support

For questions, issues, or feature requests:
- Open an issue on [GitHub](https://github.com/Lenno-skill/NixOs-Shell-Switcher/issues)
- Check the [technical documentation](modules/home/scripts/SHELLSWITCHER-README.md)
- Review the [user guide](SHELL-SWITCHER.md) (German)

---

**Made with ❤️ for the NixOS community**
