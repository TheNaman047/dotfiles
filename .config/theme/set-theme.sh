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
# ponytail: highlight/selection use each theme's "bright black" ANSI slot (distinct from
# bg_bar) so the active window/pane border is actually visible, not identical to inactive.
# Everforest's own bright-black (#a6b0a0) was too light to read, so its pair below is its
# real bg4 surface tone instead - not sourced from ghostty like the rest of this file.
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
everforest-dark-hard|Everforest Dark Hard|Everforest Dark Hard|colors|text=#d3c6aa bg_bar=#2d353b bg_pane=#1e2326 highlight=#495156 selection=#495156 info=#83c092 accent=#7fbbb3 notice=#dbbc7f error=#e67e80 muted=#d699b6 alert=#dbbc7f
gruvbox-material-dark|Gruvbox Material Dark|Gruvbox Material Dark|colors|text=#d4be98 bg_bar=#32302f bg_pane=#282828 highlight=#7c6f64 selection=#7c6f64 info=#89b482 accent=#7daea3 notice=#d8a657 error=#ea6962 muted=#d3869b alert=#d8a657
nightfox|Nightfox|Nightfox|colors|text=#cdcecf bg_bar=#2b3b51 bg_pane=#192330 highlight=#575860 selection=#575860 info=#63cdcf accent=#719cd6 notice=#dbc074 error=#c94f6d muted=#9d79d6 alert=#dbc074
duskfox|Duskfox|Duskfox|colors|text=#e0def4 bg_bar=#433c59 bg_pane=#232136 highlight=#544d8a selection=#544d8a info=#9ccfd8 accent=#569fba notice=#f6c177 error=#eb6f92 muted=#c4a7e7 alert=#f6c177
nordfox|Nordfox|Nordfox|colors|text=#cdcecf bg_bar=#3e4a5b bg_pane=#2e3440 highlight=#53648d selection=#53648d info=#88c0d0 accent=#81a1c1 notice=#ebcb8b error=#bf616a muted=#b48ead alert=#ebcb8b
carbonfox|Carbonfox|Carbonfox|colors|text=#f2f4f8 bg_bar=#2a2a2a bg_pane=#161616 highlight=#484848 selection=#484848 info=#33b1ff accent=#78a9ff notice=#08bdba error=#ee5396 muted=#be95ff alert=#08bdba
terafox|Terafox|Terafox|colors|text=#e6eaea bg_bar=#293e40 bg_pane=#152528 highlight=#4e5157 selection=#4e5157 info=#a1cdd8 accent=#5a93aa notice=#fda47f error=#e85c51 muted=#ad5c7c alert=#fda47f
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
