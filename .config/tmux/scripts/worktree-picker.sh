#!/usr/bin/env bash
# Fuzzy-pick a git worktree and open it in a new tmux window

PANE_PATH="${1:-$PWD}"

selected=$(
  git -C "$PANE_PATH" worktree list --porcelain 2>/dev/null \
    | awk '/^worktree / {path=$2} /^branch / {sub("refs/heads/","", $2); print $2 "|" path}' \
    | fzf --reverse --header "Select worktree" --delimiter="|" --with-nth=1
)

[ -z "$selected" ] && exit 0

worktree_path=$(echo "$selected" | cut -d'|' -f2)
window_name=$(basename "$worktree_path" | tr './' '__')
port=$(shuf -i 10000-65000 -n 1)

tmux new-window -n "$window_name" -c "$worktree_path"
tmux split-window -hl 30% -c "$worktree_path" "opencode --port $port"
tmux select-pane -L
tmux send-keys "nvim ." Enter
