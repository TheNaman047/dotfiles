#!/bin/bash

SESSION="ai-emotion"
DEV_DIR="$HOME/Projects/ai-emotion-analysis/code"
SUB_DIRS=(
    "ai-emotion-backend"
    "ai-emotion-ui"
    "ai-emotion-ml-v2"
    "ai-emotion-ml-v3"
)

if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux switch-client -t "$SESSION"
    exit 0
fi

tmux new-session -d -s "$SESSION" -c "$DEV_DIR"

for i in "${!SUB_DIRS[@]}"; do
    subdir="${SUB_DIRS[$i]}"
    window_name="code-${subdir#ai-emotion-}"
    
    if [ $i -eq 0 ]; then
        # Rename the first window (already exists)
        tmux rename-window -t "$SESSION:1" "$window_name"
        sleep 0.5
        tmux send-keys -t "$SESSION:1" "cd $subdir && nvim ." Enter
    else
        # Create new windows for remaining subdirectories
        tmux new-window -t "$SESSION" -c "$DEV_DIR/$subdir" -n "$window_name"
        sleep 0.5
        tmux send-keys -t "$SESSION:$(($i + 1))" "nvim ." Enter
    fi
done

tmux new-window -t "$SESSION" -c "$DEV_DIR" -n "server"
tmux send-keys -t "$SESSION:5" "ssh ai-emotion-gpu-dev" Enter

tmux select-window -t "$SESSION:1"
tmux switch-client -t "$SESSION"
