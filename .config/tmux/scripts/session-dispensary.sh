#!/bin/bash

DIRS=(
    "$HOME/documents"
    "$HOME"
    "$HOME/documents/notes"
    "$HOME/documents/projects"
)

if [[ $# -eq 1 ]]; then
    selected=$(fd . "$1" --type=dir --max-depth=3 --full-path \
        | sed "s|^$HOME/||" \
        | fzf --margin 10% --color="bw")
    [[ $selected ]] && selected="$HOME/$selected"
else
    selected=$(fd "${DIRS[@]}" --type=dir --max-depth=1 --full-path \
        | sed "s|^$HOME/||" \
        | fzf --margin 10% --color="bw")
    [[ $selected ]] && selected="$HOME/$selected"
fi

[[ ! $selected ]] && exit 0

selected_name=$(basename "$selected" | tr . _)
if ! tmux has-session -t "$selected_name"; then
    tmux new-session -ds "$selected_name" -c "$selected"
    tmux select-window -t "$selected_name:1"
fi

tmux switch-client -t "$selected_name"
tmux send-keys -t "$SESSION:1.1" "nvim ." Enter
