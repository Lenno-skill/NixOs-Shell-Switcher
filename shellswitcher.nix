{ pkgs, config }:

pkgs.writeShellScriptBin "shellswitcher" ''
  #!/usr/bin/env bash
  
  # Shell Switcher - Switch between desktop shells on Hyprland
  # Supports: DankMaterialShell, Noctalia Shell, Caelestia Shell, Waybar
  
  HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"
  BACKUP_CONFIG="$HOME/.config/hypr/hyprland.conf.shellswitcher.bak"
  
  # Shell configurations
  declare -A SHELLS=(
    ["DankMaterialShell"]="dms-integration.conf"
    ["Noctalia Shell"]="noctalia-integration.conf"
    ["Caelestia Shell"]="caelestia-integration.conf"
    ["Waybar (Default)"]="waybar"
  )
  
  declare -A SHELL_COMMANDS=(
    ["DankMaterialShell"]="dms run"
    ["Noctalia Shell"]="noctalia-shell"
    ["Caelestia Shell"]="caelestia-shell -d"
    ["Waybar (Default)"]="killall -q waybar; sleep .5 && waybar"
  )
  
  # Get current shell by checking running processes
  get_current_shell() {
    # Check running processes first (most reliable)
    if ${pkgs.procps}/bin/pgrep -f "dms run" > /dev/null 2>&1; then
      echo "DankMaterialShell"
    elif ${pkgs.procps}/bin/pgrep -f "noctalia-shell" > /dev/null 2>&1; then
      echo "Noctalia Shell"
    elif ${pkgs.procps}/bin/pgrep -f "caelestia-shell" > /dev/null 2>&1; then
      echo "Caelestia Shell"
    elif ${pkgs.procps}/bin/pgrep -f "waybar" > /dev/null 2>&1; then
      echo "Waybar (Default)"
    else
      # Fallback: check config file if no process is running
      if [ -f "$HYPR_CONFIG" ]; then
        if grep -q "^source = ~/.config/hypr/dms-integration.conf" "$HYPR_CONFIG" 2>/dev/null; then
          echo "DankMaterialShell"
        elif grep -q "^source = ~/.config/hypr/noctalia-integration.conf" "$HYPR_CONFIG" 2>/dev/null; then
          echo "Noctalia Shell"
        elif grep -q "^source = ~/.config/hypr/caelestia-integration.conf" "$HYPR_CONFIG" 2>/dev/null; then
          echo "Caelestia Shell"
        else
          echo "Waybar (Default)"
        fi
      else
        echo "Waybar (Default)"
      fi
    fi
  }
  
  # Display selection menu with rofi
  CURRENT_SHELL=$(get_current_shell)
  
  # Build menu with current selection marked
  MENU=""
  for shell in "''${!SHELLS[@]}"; do
    if [ "$shell" = "$CURRENT_SHELL" ]; then
      MENU="$MENU● $shell (active)\n"
    else
      MENU="$MENU  $shell\n"
    fi
  done
  
  # Show rofi selection
  SELECTION=$(echo -e "$MENU" | ${pkgs.rofi-wayland}/bin/rofi -dmenu -i -p "Switch Shell" -config "$HOME/.config/rofi/shellswitcher.rasi" | sed 's/[●]//g' | sed 's/(active)//g' | xargs)
  
  if [ -z "$SELECTION" ]; then
    echo "❌ No shell selected"
    exit 0
  fi
  
  echo "🔄 Switching to: $SELECTION"
  
  # Create backup
  cp "$HYPR_CONFIG" "$BACKUP_CONFIG"
  
  # Kill all running shells
  ${pkgs.procps}/bin/pkill -f "dms run" 2>/dev/null || true
  ${pkgs.procps}/bin/pkill -f "noctalia-shell" 2>/dev/null || true
  ${pkgs.procps}/bin/pkill -f "caelestia-shell" 2>/dev/null || true
  ${pkgs.procps}/bin/pkill -f "waybar" 2>/dev/null || true
  
  sleep 0.5
  
  # Comment out all shell integrations in hyprland.conf
  ${pkgs.gnused}/bin/sed -i 's|^source = ~/.config/hypr/dms-integration.conf|#source = ~/.config/hypr/dms-integration.conf|g' "$HYPR_CONFIG"
  ${pkgs.gnused}/bin/sed -i 's|^source = ~/.config/hypr/noctalia-integration.conf|#source = ~/.config/hypr/noctalia-integration.conf|g' "$HYPR_CONFIG"
  ${pkgs.gnused}/bin/sed -i 's|^source = ~/.config/hypr/caelestia-integration.conf|#source = ~/.config/hypr/caelestia-integration.conf|g' "$HYPR_CONFIG"
  
  # Activate selected shell
  case "$SELECTION" in
    "DankMaterialShell")
      ${pkgs.gnused}/bin/sed -i 's|^#source = ~/.config/hypr/dms-integration.conf|source = ~/.config/hypr/dms-integration.conf|g' "$HYPR_CONFIG"
      dms run &
      ;;
    "Noctalia Shell")
      ${pkgs.gnused}/bin/sed -i 's|^#source = ~/.config/hypr/noctalia-integration.conf|source = ~/.config/hypr/noctalia-integration.conf|g' "$HYPR_CONFIG"
      noctalia-shell &
      ;;
    "Caelestia Shell")
      ${pkgs.gnused}/bin/sed -i 's|^#source = ~/.config/hypr/caelestia-integration.conf|source = ~/.config/hypr/caelestia-integration.conf|g' "$HYPR_CONFIG"
      caelestia-shell -d &
      ;;
    "Waybar (Default)")
      # Just start waybar, no integration file needed
      killall -q waybar; sleep .5 && waybar &
      ;;
    *)
      echo "❌ Unknown shell: $SELECTION"
      cp "$BACKUP_CONFIG" "$HYPR_CONFIG"
      exit 1
      ;;
  esac
  
  echo "✨ Shell switched! Hyprland reload recommended:"
  echo "   hyprctl reload"
  
  # Optional: Auto-reload Hyprland
  ${pkgs.hyprland}/bin/hyprctl reload 2>/dev/null || true
  
  ${pkgs.libnotify}/bin/notify-send "Shell Switcher" "Switched to: $SELECTION" -i preferences-desktop-theme
''
