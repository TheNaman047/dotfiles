#!/bin/bash

# Development Workspace Setup
SESSION="coverstar"
DEV_DIR="$HOME/Projects/norae/code/spotlight-backend"

# Check if session exists
if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux switch-client -t "$SESSION"
    exit 0
fi

# Create new session
tmux new-session -d -s "$SESSION" -c "$DEV_DIR"

# Window 1: Code (Editor + Terminal)
tmux rename-window -t "$SESSION:1" "code"

# Send commands
sleep 1
tmux send-keys -t "$SESSION:1.1" "nvim" Enter
sleep 0.5
tmux send-keys -t "$SESSION:1.1" "Space" "t"
tmux send-keys -t "$SESSION:1.1" "export AWS_PROFILE=coverstar-dev" Enter
tmux send-keys -t "$SESSION:1.1" "aws sso login" Enter

# Window 2: DB - dev
tmux new-window -t "$SESSION" -c "$DEV_DIR" -n "db-dev"
tmux send-keys -t "$SESSION:2" "nvim" Enter

# Window 3: DB - prod
tmux new-window -t "$SESSION" -c "$DEV_DIR" -n "db-prod"
tmux send-keys -t "$SESSION:3" "nvim" Enter

# Select first window and pane
tmux select-window -t "$SESSION:1"

# Attach to session
tmux switch-client -t "$SESSION"
