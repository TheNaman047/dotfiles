#!/usr/bin/env bash
# Also appends Claude Code agent status icons to the window name (see below).
#
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

# One glyph per pane running a Claude Code agent, from the @claude_state pane
# option that claude-status.sh maintains: cog = working, question = waiting on
# you (permission/question), check = finished since you last looked.
# nf-fa-cog, nf-fa-question_circle, nf-fa-check_circle.
agent_icon() { printf '#{?#{==:#{@claude_state},%s}, #[fg=%s]%s,}' "$1" "$2" "$3"; }
agents="#{P:$(agent_icon working yellow $'')$(agent_icon waiting red $'')$(agent_icon done green $'')}"

for opt in window-status-format window-status-current-format; do
  current="$(tmux show -gvw "$opt" 2>/dev/null || true)"
  [ -n "$current" ] || continue
  patched="${current//"$placeholder"/$icons}"
  # Right after the name; the flags segment that may follow sets its own fg.
  [[ "$patched" == *@claude_state* ]] || patched="${patched/" #W"/" #W$agents"}"
  if [ "$patched" != "$current" ]; then
    tmux set-window-option -g "$opt" "$patched"
  fi
done
