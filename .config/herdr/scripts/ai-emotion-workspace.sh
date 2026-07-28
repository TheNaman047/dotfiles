#!/usr/bin/env bash
# herdr port of ~/.config/tmux/scripts/ai-emotion-workspace.sh
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

LABEL="ai-emotion"
DEV_DIR="$HOME/Projects/ai-emotion-analysis/code"
SUB_DIRS=(ai-emotion-backend ai-emotion-ui ai-emotion-docs ai-emotion-ml-v3)

focus_existing "$LABEL" && exit 0

first="${SUB_DIRS[0]}"
read -r ws tab pane < <(ws_create "$LABEL" "$DEV_DIR/$first")

herdr tab rename "$tab" "code-${first#ai-emotion-}" >/dev/null
herdr pane run "$pane" "nvim ."

for subdir in "${SUB_DIRS[@]:1}"; do
  p=$(tab_add "$ws" "code-${subdir#ai-emotion-}" "$DEV_DIR/$subdir")
  herdr pane run "$p" "nvim ."
done

p=$(tab_add "$ws" server "$DEV_DIR")
herdr pane run "$p" "ssh ai-emotion-gpu-dev"

herdr tab focus "$tab" >/dev/null
