#!/bin/bash

DIRS=(
    "$HOME/Projects"
)

if [[ $# -eq 1 ]]; then
    selected=$(fd . "$1" --type=dir --max-depth=3 --full-path \
        | sed "s|^$HOME/||" \
        | fzf --margin 10% --color="bw")
    [[ $selected ]] && selected="$HOME/$selected"
else
    # Merge zoxide frecency-ranked dirs with fd results, deduplicate, then fzf
    zoxide_dirs=$(zoxide query --list 2>/dev/null | head -20)
    fd_dirs=$(printf '%s\n' \
        "$(fd "${DIRS[@]}" --type=dir --max-depth=1 --full-path 2>/dev/null)" \
        "$(fd . "$HOME/dotfiles/.config" --type=dir --max-depth=1 --full-path 2>/dev/null)")
    selected=$(printf '%s\n%s\n' "$zoxide_dirs" "$fd_dirs" \
        | awk '!seen[$0]++' \
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
tmux send-keys -t "$selected_name:1.1" "nvim ." Enter
