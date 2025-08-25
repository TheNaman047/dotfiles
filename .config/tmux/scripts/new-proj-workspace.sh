#!/bin/bash

# Function to setup the project
setup_project() {
    local repo_url="$1"
    
    # Validate that repo_url is not empty
    if [[ -z "$repo_url" ]]; then
        tmux display-message "Error: No repository URL provided"
        exit 1
    fi

    cd ~/Projects 
    # Extract repository name from URL
    SESSION=$(basename -s .git "$repo_url")

    # Create project structure
    mkdir -p "$SESSION" && cd "$SESSION" && mkdir -p code docs

    # Set up directories
    PROJECT_DIR="$HOME/Projects/$SESSION"
    CODE_DIR="$PROJECT_DIR/code"

    # Clone the repository into the code directory
    cd "$CODE_DIR" || exit 1
    git clone "$repo_url" || {
        tmux display-message "Error: Failed to clone repository"
        exit 1
    }

    # Get the actual cloned directory name (in case it differs from repo_name)
    cloned_dir=$(find . -maxdepth 1 -type d -name "*" | grep -v "^\.$" | head -n 1)
    if [[ -n "$cloned_dir" ]]; then
        CODE_DIR="$CODE_DIR/${cloned_dir#./}"
    fi

    # Check if session already exists
    if tmux has-session -t "$SESSION" 2>/dev/null; then
        tmux display-message "Session '$SESSION' already exists. Switching to it..."
        tmux switch-client -t "$SESSION"
        exit 0
    fi

    # Create new session
    tmux new-session -d -s "$SESSION" -c "$CODE_DIR"

    # Rename the first window
    tmux rename-window -t "$SESSION:1" "code"

    # Open nvim in the first pane
    tmux send-keys -t "$SESSION:1.1" "nvim ." Enter

    # Switch to the session
    tmux switch-client -t "$SESSION"
}

# If called with an argument (from tmux command-prompt), setup the project
if [[ $# -eq 1 ]]; then
    setup_project "$1"
else
    # This will be called from tmux key binding
    # The command-prompt will call this script again with the repo URL as argument
    tmux command-prompt -p "New project git: " "run-shell '$0 \"%%\"'"
fi
