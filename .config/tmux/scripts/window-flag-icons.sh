#!/usr/bin/env bash
# ukiyo renders window flags as the raw #{window_flags} string, so a zoomed pane
# shows a bare "Z" (and "*" for the current window, which its background already
# marks). Rewrite just the flags placeholder inside whatever format ukiyo built:
# drop "*", swap "Z" for a fullscreen glyph, leave activity/bell/silence/marked
# alone - monitor-activity is on deliberately (see tmux.configuration.conf).
#
# Substituting in place rather than re-declaring the format keeps ukiyo's theme
# colours and its powerline variant intact. ukiyo owns these options, so this has
# to run after it: once from tmux.conf (after tpm) and again from set-theme.sh
# (after it re-runs ukiyo.sh). Idempotent - the result no longer contains the
# placeholder, so re-running is a no-op.
set -euo pipefail

# nf-fa-expand, kept as a codepoint escape - a literal Private Use Area glyph is
# unreadable in a diff and easy to mangle when editing.
zoom_icon=$'\uf065'

placeholder='#{window_flags}'
icons='#{s/\*//:#{s/Z/ '"$zoom_icon"'/:window_flags}}'

for opt in window-status-format window-status-current-format; do
  current="$(tmux show -gvw "$opt" 2>/dev/null || true)"
  [ -n "$current" ] || continue
  patched="${current//"$placeholder"/$icons}"
  if [ "$patched" != "$current" ]; then
    tmux set-window-option -g "$opt" "$patched"
  fi
done
