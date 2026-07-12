#!/usr/bin/env bash
# Fuzzy-pick a theme and apply it across ghostty, tmux, and nvim
set -euo pipefail

selected=$(
  ~/.config/theme/set-theme.sh --list |
    fzf --reverse --header 'select a theme' --with-nth=2 --delimiter='\t' |
    cut -f1
)

[ -n "$selected" ] && ~/.config/theme/set-theme.sh "$selected"
