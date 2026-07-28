#!/usr/bin/env bash
# Shared helpers for the herdr workspace scripts (ported from ~/.config/tmux/scripts).
# herdr's CLI answers in JSON, so every helper pipes through jq.

ws_find() {
  herdr workspace list 2>/dev/null |
    jq -r --arg l "$1" '.result.workspaces[]? | select(.label==$l) | .workspace_id' |
    head -1
}

# ws_create LABEL CWD -> "<workspace_id> <tab_id> <pane_id>"
ws_create() {
  herdr workspace create --cwd "$2" --label "$1" --focus |
    jq -r '.result | "\(.workspace.workspace_id) \(.tab.tab_id) \(.root_pane.pane_id)"'
}

# tab_add WORKSPACE_ID LABEL CWD -> pane_id of the new tab's root pane
tab_add() {
  herdr tab create --workspace "$1" --label "$2" --cwd "$3" --no-focus |
    jq -r '.result.root_pane.pane_id'
}

# Focus an existing workspace with this label; return 0 if one was found.
focus_existing() {
  local id
  id=$(ws_find "$1")
  [ -n "$id" ] || return 1
  herdr workspace focus "$id" >/dev/null
}
