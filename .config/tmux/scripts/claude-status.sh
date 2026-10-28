#!/usr/bin/env bash
# Track a Claude Code session's state on the tmux pane it runs in, so the window
# tab can show it (the format is patched in by window-flag-icons.sh).
#
#   claude-status.sh working|waiting|done|idle|clear - from Claude Code hooks
#   claude-status.sh seen <target>                - from tmux hooks: drop "done"
#                                                   on the panes of <target>
#
# The state lives in the pane option @claude_state on $TMUX_PANE. nvim passes
# TMUX/TMUX_PANE through to :terminal jobs, so an agent inside nvim marks the
# pane nvim runs in. Hook stdout is fed back to Claude, so nothing is printed.

state="${1:-}"

if [ "$state" = seen ]; then
  tmux list-panes -t "$2" -F '#{pane_id} #{@claude_state}' 2>/dev/null |
    while read -r pane s; do
      [ "$s" = done ] && tmux set -pu -t "$pane" @claude_state
    done
  exit 0
fi

[ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ] || exit 0

case "$state" in
  working | waiting)
    tmux set -p -t "$TMUX_PANE" @claude_state "$state"
    ;;
  done)
    # Already looking at it: nothing to flag.
    if [ "$(tmux display -p -t "$TMUX_PANE" '#{&&:#{pane_active},#{&&:#{window_active},#{session_attached}}}')" = 1 ]; then
      tmux set -pu -t "$TMUX_PANE" @claude_state
    else
      tmux set -p -t "$TMUX_PANE" @claude_state done
    fi
    ;;
  clear)
    tmux set -pu -t "$TMUX_PANE" @claude_state
    ;;
  idle)
    # Esc-interrupted turns never fire Stop; idle_prompt is the only sign the
    # cog is stale. Leave "done"/"waiting" alone.
    [ "$(tmux display -p -t "$TMUX_PANE" '#{@claude_state}')" = working ] &&
      tmux set -pu -t "$TMUX_PANE" @claude_state
    ;;
  *) exit 0 ;;
esac 2>/dev/null

# Option changes don't redraw the status line until status-interval ticks.
tmux list-clients -F '#{client_name}' 2>/dev/null |
  while read -r c; do tmux refresh-client -S -t "$c"; done
exit 0
