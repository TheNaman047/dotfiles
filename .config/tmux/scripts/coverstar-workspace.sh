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
# tmux split-window -h -t "$SESSION:1" -c "$DEV_DIR"
# tmux resize-pane -t "$SESSION:1.2" -x 30%

# Send commands
tmux send-keys -t "$SESSION:1.1" "nvim" Enter
tmux send-keys -t "$SESSION:1.2" "git status && echo 'Ready for development!'" Enter

# Window 2: Git Operations
# tmux new-window -t "$SESSION" -c "$DEV_DIR" -n "git"
# tmux send-keys -t "$SESSION:git" "lazygit" Enter

# Window 2: DB - dev
tmux new-window -t "$SESSION" -c "$DEV_DIR" -n "db-dev"
tmux send-keys -t "$SESSION:1.2" "nvim" Enter

# Window 3: DB - prod
tmux new-window -t "$SESSION" -c "$DEV_DIR" -n "db-prod"
tmux send-keys -t "$SESSION:1.3" "nvim" Enter

# Select first window and pane
tmux select-window -t "$SESSION:1"
# tmux select-pane -t "$SESSION:1.1"

# Attach to session
tmux switch-client -t "$SESSION"
