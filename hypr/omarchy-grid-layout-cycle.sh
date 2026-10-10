#!/bin/bash
# Cycle the layout of the active workspace: dwindle -> scrolling -> grid.
# The choice is saved the same way as omarchy-hyprland-workspace-layout-toggle,
# so Omarchy restores it on reload and login.

ACTIVE_WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')
[[ $ACTIVE_WORKSPACE =~ ^-?[0-9]+$ ]] || exit 1
LAYOUTS_DIR="$HOME/.local/state/omarchy/workspace-layouts"
LAYOUT_FILE="$LAYOUTS_DIR/$ACTIVE_WORKSPACE.lua"

# tiledLayout does not report Lua layouts, so read the saved choice first.
CURRENT_LAYOUT=$(grep -oP 'layout = "\K[^"]+' "$LAYOUT_FILE" 2>/dev/null)
[[ -n $CURRENT_LAYOUT ]] || CURRENT_LAYOUT=$(hyprctl activeworkspace -j | jq -r '.tiledLayout')

case "$CURRENT_LAYOUT" in
  dwindle) NEW_LAYOUT=scrolling ;;
  scrolling) NEW_LAYOUT=lua:grid ;;
  *) NEW_LAYOUT=dwindle ;;
esac

mkdir -p "$LAYOUTS_DIR"
printf 'hl.workspace_rule({ workspace = "%s", layout = "%s" })\n' "$ACTIVE_WORKSPACE" "$NEW_LAYOUT" >"$LAYOUT_FILE"

# After a runtime layout change Hyprland places the windows correctly but does
# not always send the final size to the clients, so terminals keep drawing at
# their old size (text wraps early, the wallpaper shows through the rest).
# Bumping gaps_in by one pixel and back forces a new configure. It is sent in
# the same batch as the layout change so there is no visible flash.
GAPS_IN=$(hyprctl getoption general:gaps_in | grep -oP 'gap data: \K[0-9]+')
GAPS_IN=${GAPS_IN:-5}
hyprctl --batch "eval hl.workspace_rule({ workspace = \"$ACTIVE_WORKSPACE\", layout = \"$NEW_LAYOUT\" }) ; eval hl.config({ general = { gaps_in = $((GAPS_IN + 1)) } })" >/dev/null
hyprctl eval "hl.config({ general = { gaps_in = $GAPS_IN } })" >/dev/null

omarchy-notification-send -g 󱂬 "Workspace layout set to ${NEW_LAYOUT#lua:}"
