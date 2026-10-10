#!/bin/bash
# Install omarchy-grid-layout into ~/.config/hypr.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_DIR="$HOME/.config/hypr"
HYPRLAND_LUA="$HYPR_DIR/hyprland.lua"
REQUIRE_LINE='require("hypr.grid-layout")'

if [[ ! -f $HYPRLAND_LUA ]]; then
  echo "Could not find $HYPRLAND_LUA. Is this an Omarchy system with the Lua config (Hyprland 0.55+)?" >&2
  exit 1
fi

mkdir -p "$HYPR_DIR/scripts"
install -m 644 "$REPO_DIR/hypr/grid-layout.lua" "$HYPR_DIR/grid-layout.lua"
install -m 755 "$REPO_DIR/hypr/omarchy-grid-layout-cycle.sh" "$HYPR_DIR/scripts/omarchy-grid-layout-cycle.sh"

if ! grep -qxF "$REQUIRE_LINE" "$HYPRLAND_LUA"; then
  cp "$HYPRLAND_LUA" "$HYPRLAND_LUA.bak.$(date +%s)"
  # The layout must be registered before Omarchy restores saved workspace
  # layouts in default.hypr.toggles.
  # Insert above that line, and above the comment directly over it.
  if grep -qxF 'require("default.hypr.toggles")' "$HYPRLAND_LUA"; then
    awk -v req="$REQUIRE_LINE" '
      { lines[NR] = $0 }
      $0 == "require(\"default.hypr.toggles\")" { target = NR }
      END {
        at = target
        while (at > 1 && lines[at - 1] ~ /^--/) at--
        for (i = 1; i <= NR; i++) {
          if (i == at) print req "\n"
          print lines[i]
        }
      }' "$HYPRLAND_LUA" >"$HYPRLAND_LUA.tmp" && mv "$HYPRLAND_LUA.tmp" "$HYPRLAND_LUA"
  else
    printf '\n%s\n' "$REQUIRE_LINE" >>"$HYPRLAND_LUA"
  fi
fi

hyprctl reload >/dev/null
errors=$(hyprctl configerrors)
if [[ -n ${errors//[[:space:]]/} ]]; then
  echo "Hyprland reported config errors:" >&2
  echo "$errors" >&2
  exit 1
fi

echo "Installed. Press SUPER + L to cycle dwindle -> scrolling -> grid."
