#!/bin/bash
# Remove omarchy-grid-layout and restore Omarchy's default SUPER + L toggle.
set -euo pipefail

HYPR_DIR="$HOME/.config/hypr"
HYPRLAND_LUA="$HYPR_DIR/hyprland.lua"
LAYOUTS_DIR="$HOME/.local/state/omarchy/workspace-layouts"

if [[ -f $HYPRLAND_LUA ]] && grep -qxF 'require("hypr.grid-layout")' "$HYPRLAND_LUA"; then
  cp "$HYPRLAND_LUA" "$HYPRLAND_LUA.bak.$(date +%s)"
  # Remove the line and the blank line install.sh added after it.
  sed -i '/^require("hypr\.grid-layout")$/{N;/\n$/d;s/^[^\n]*\n//}' "$HYPRLAND_LUA"
fi

rm -f "$HYPR_DIR/grid-layout.lua" "$HYPR_DIR/scripts/omarchy-grid-layout-cycle.sh"

# Workspaces saved as grid fall back to dwindle.
if [[ -d $LAYOUTS_DIR ]]; then
  grep -lF 'layout = "lua:grid"' "$LAYOUTS_DIR"/*.lua 2>/dev/null | xargs -r sed -i 's/layout = "lua:grid"/layout = "dwindle"/'
fi

hyprctl reload >/dev/null
echo "Uninstalled. SUPER + L is back to Omarchy's dwindle/scrolling toggle."
