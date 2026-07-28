#!/usr/bin/env bash
# herdr port of ~/.config/tmux/scripts/new-proj-workspace.sh
# Runs as a popup, so the tmux command-prompt becomes a plain read.
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

repo_url="${1:-}"
if [ -z "$repo_url" ]; then
  read -r -p "New project git: " repo_url
fi
[ -n "$repo_url" ] || exit 0

name=$(basename -s .git "$repo_url")
proj="$HOME/Projects/$name"
code_dir="$proj/code/$name"

focus_existing "$name" && exit 0

mkdir -p "$proj/code" "$proj/docs"
if [ ! -d "$code_dir/.git" ]; then
  git clone "$repo_url" "$code_dir" || { echo "clone failed"; read -r -p "press enter"; exit 1; }
fi

read -r ws tab pane < <(ws_create "$name" "$code_dir")
herdr tab rename "$tab" code >/dev/null
herdr pane run "$pane" "nvim ."
