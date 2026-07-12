#!/usr/bin/env bash
# Apply one theme key across ghostty, tmux, and nvim
set -euo pipefail

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GHOSTTY_THEME_FILE="$HOME/.config/ghostty/theme.conf"
TMUX_ACTIVE_FILE="$HOME/.config/tmux/theme-active.conf"
CURRENT_FILE="$THEME_DIR/current"
UKIYO_APPLY="$HOME/.config/tmux/plugins/tmux-ukiyo/scripts/ukiyo.sh"

# key|Label|ghostty theme name|mode|value
# mode=native -> value is the @ukiyo-theme string (tmux-ukiyo ships this family)
# mode=colors -> value is space-separated name=hex pairs for @ukiyo-color-*
# ponytail: everforest/gruvbox-material/nightfox collapse bg_bar+highlight+selection to one
# derived surface shade (only one panel tone was extracted per theme). Upgrade path: pull that
# theme's real bg1/bg2/bg3 constants from its own palette source if finer gradation is wanted.
THEMES="
kanagawa-wave|Kanagawa Wave|Kanagawa Wave|native|kanagawa/wave
catppuccin-mocha|Catppuccin Mocha|Catppuccin Mocha|native|catppuccin/mocha
tokyonight-storm|Tokyo Night Storm|TokyoNight Storm|native|tokyonight/storm
rose-pine-moon|Rose Pine Moon|Rose Pine Moon|native|rose-pine/moon
dracula|Dracula|Dracula|native|dracula/classic
gruvbox-dark|Gruvbox Dark|Gruvbox Dark|native|gruvbox/dark
nord|Nord|Nord|native|nord/default
solarized-dark|Solarized Dark|iTerm2 Solarized Dark|native|solarized/dark
onedark|OneDark|Atom One Dark|native|onedark/dark
everforest-dark-hard|Everforest Dark Hard|Everforest Dark Hard|colors|text=#d3c6aa bg_bar=#2d353b bg_pane=#1e2326 highlight=#2d353b selection=#2d353b info=#83c092 accent=#7fbbb3 notice=#dbbc7f error=#e67e80 muted=#d699b6 alert=#dbbc7f
gruvbox-material-dark|Gruvbox Material Dark|Gruvbox Material Dark|colors|text=#d4be98 bg_bar=#32302f bg_pane=#282828 highlight=#32302f selection=#32302f info=#89b482 accent=#7daea3 notice=#d8a657 error=#ea6962 muted=#d3869b alert=#d8a657
nightfox|Nightfox|Nightfox|colors|text=#cdcecf bg_bar=#2b3b51 bg_pane=#192330 highlight=#2b3b51 selection=#2b3b51 info=#63cdcf accent=#719cd6 notice=#dbc074 error=#c94f6d muted=#9d79d6 alert=#dbc074
"

usage() {
  echo "Usage: $(basename "$0") [--list] <theme-key>" >&2
  exit 1
}

if [ "${1:-}" = "--list" ]; then
  echo "$THEMES" | sed '/^$/d' | awk -F'|' '{print $1"\t"$2}'
  exit 0
fi

key="${1:-}"
[ -n "$key" ] || usage

line="$(echo "$THEMES" | awk -F'|' -v k="$key" '$1==k')"
[ -n "$line" ] || {
  echo "Unknown theme: $key (try --list)" >&2
  exit 1
}

IFS='|' read -r _ label ghostty_name mode value <<<"$line"
semantic_names="text bg_bar bg_pane highlight selection info accent notice error muted alert"

# Ghostty has no CLI/signal reload, so simulate its own reload_config keybind
printf 'theme = %s\n' "$ghostty_name" >"$GHOSTTY_THEME_FILE"
osascript -e 'tell application "System Events" to keystroke "r" using {command down, option down}' 2>/dev/null || true

# Persist to theme-active.conf too, so tmux picks the same theme back up after a server restart
{
  if [ "$mode" = "native" ]; then
    echo "set -g @ukiyo-theme \"$value\""
    for name in $semantic_names; do
      echo "set -gu @ukiyo-color-${name//_/-}"
    done
  else
    echo 'set -gu @ukiyo-theme'
    for pair in $value; do
      name="${pair%%=*}"
      hex="${pair#*=}"
      echo "set -g @ukiyo-color-${name//_/-} \"$hex\""
    done
  fi
} >"$TMUX_ACTIVE_FILE"

if tmux info >/dev/null 2>&1; then
  tmux source-file "$TMUX_ACTIVE_FILE"
  tmux run-shell "$UKIYO_APPLY"
  tmux display-message "Theme: $label"
fi

# nvim: state only, intentionally not reloaded live (see lua/plugins/theme.lua)
echo "$key" >"$CURRENT_FILE"
