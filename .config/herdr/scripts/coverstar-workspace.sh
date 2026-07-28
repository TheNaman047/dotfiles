#!/usr/bin/env bash
# herdr port of ~/.config/tmux/scripts/coverstar-workspace.sh
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

LABEL="coverstar"
DEV_DIR="$HOME/Projects/coverstar/code/spotlight-backend"

focus_existing "$LABEL" && exit 0

read -r ws tab pane < <(ws_create "$LABEL" "$DEV_DIR")

herdr tab rename "$tab" code >/dev/null
# tmux sent the AWS setup after nvim had already taken the pane; run it first.
herdr pane run "$pane" "export AWS_PROFILE=coverstar-dev && aws sso login && nvim ."

for t in db-dev db-prod; do
  p=$(tab_add "$ws" "$t" "$DEV_DIR")
  herdr pane run "$p" "nvim -c DBUI"
done

herdr tab focus "$tab" >/dev/null
