# Shell Switcher (NixOS + Hyprland)

Switch between desktop shells (DankMaterialShell, Noctalia, Caelestia, Waybar) live on Hyprland. 

## Features
- Instant switching (no logout)
- Active shell detection
- Hyprland auto-reload

## Install (flakes + Home Manager)
- Add input:
  inputs.shellswitcher.url = "github:<your-username>/shellswitcher";
- Use:
  - Add `(import ./modules/scripts/shellswitcher.nix { inherit pkgs config; })` to `home.packages`.
  - Link Rofi config:
    - `~/.config/rofi/shellswitcher.rasi`
    - `~/.config/rofi/themes/shellswitcher.rasi`
- Rebuild and run `shellswitcher`.

## How it works
- Detects current shell via processes (pgrep), falls back to `hyprland.conf`
- Presents menu via Rofi
- Stops old shell, toggles Hyprland `source = ...` lines, starts new shell
- Reloads Hyprland and notifies

## Shortcuts
Bind: `SUPER+ALT+S → shellswitcher`
