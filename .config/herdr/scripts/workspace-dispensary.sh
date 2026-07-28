#!/usr/bin/env bash
# herdr port of ~/.config/tmux/scripts/session-dispensary.sh
# tmux sessions become herdr workspaces; everything else is unchanged.
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

DIRS=("$HOME/Projects")

if [[ $# -eq 1 ]]; then
  selected=$(fd . "$1" --type=dir --max-depth=3 --full-path |
    sed "s|^$HOME/||" |
    fzf --margin 10% --color="bw")
else
  # Merge zoxide frecency-ranked dirs with fd results, deduplicate, then fzf
  zoxide_dirs=$(zoxide query --list 2>/dev/null | head -20)
  fd_dirs=$(printf '%s\n' \
    "$(fd . "${DIRS[@]}" --type=dir --max-depth=3 --full-path 2>/dev/null)" \
    "$(fd . "$HOME/dotfiles/.config" --type=dir --max-depth=1 --full-path 2>/dev/null)")
  selected=$(printf '%s\n%s\n' "$zoxide_dirs" "$fd_dirs" |
    awk '!seen[$0]++' |
    sed "s|^$HOME/||" |
    fzf --margin 10% --color="bw")
fi

[[ -n ${selected:-} ]] || exit 0
selected="$HOME/$selected"

label=$(basename "$selected" | tr . _)

focus_existing "$label" && exit 0

read -r ws tab pane < <(ws_create "$label" "$selected")
herdr pane run "$pane" "nvim ."
