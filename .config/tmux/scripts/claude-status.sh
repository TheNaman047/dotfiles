#!/usr/bin/env bash
# Track Claude Code session state on the tmux pane it belongs to, so the window
# tab can show it (the format is patched in by window-flag-icons.sh).
#
#   claude-status.sh working|waiting|done|idle|clear - from Claude Code hooks
#   claude-status.sh seen <target>                   - from tmux hooks: drop "done"
#                                                      on the panes of <target>
#
# Each session's state is a file under $dir/<pane>/<session_id>; the pane option
# @claude_state is the most urgent of them (waiting > working > done), so several
# agents behind one pane don't overwrite each other.
#
# Which pane: $TMUX_PANE when Claude runs in a terminal inside tmux (nvim passes
# it through to :terminal jobs). Sessions started from `claude agents` run in the
# claude daemon, which has no tmux env; those map to the pane running a
# `claude agents` dashboard for the same git repository.
# Hook stdout is fed back to Claude, so nothing is printed.

dir="$HOME/.cache/claude-tmux-status"

# Recompute a pane's @claude_state from its session files.
sync_pane() {
  local pane="$1" s best=""
  for s in waiting working done; do
    if grep -qx "$s" "$dir/$pane"/* 2>/dev/null; then best="$s"; break; fi
  done
  if [ -n "$best" ]; then
    tmux set -p -t "$pane" @claude_state "$best"
  else
    tmux set -pu -t "$pane" @claude_state
  fi
}

refresh() {
  tmux list-clients -F '#{client_name}' 2>/dev/null |
    while read -r c; do tmux refresh-client -S -t "$c"; done
}

repo_of() {
  git -C "$1" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || echo "$1"
}

# Pane hosting a `claude agents` dashboard whose repo matches $1.
dashboard_pane() {
  local want pane_pids
  want="$(repo_of "$1")"
  # One line: BSD awk rejects newlines in -v values.
  pane_pids="$(tmux list-panes -a -F '#{pane_pid}=#{pane_id}' 2>/dev/null | tr '\n' ' ')" || return
  ps -Ao pid=,ppid=,command= | awk -v panes="$pane_pids" '
    BEGIN { n = split(panes, a, " "); for (i = 1; i <= n; i++) { split(a[i], f, "="); pane[f[1]] = f[2] } }
    { ppid[$1] = $2; if ($0 ~ /claude agents/) dash[$1] = $0 }
    END {
      for (p in dash) {
        q = p
        while (q != "" && q > 1 && !(q in pane)) q = ppid[q]
        if (q in pane) {
          cwd = ""
          if (match(dash[p], /--cwd [^ ]+/)) cwd = substr(dash[p], RSTART + 6, RLENGTH - 6)
          print pane[q], p, cwd
        }
      }
    }' |
    while read -r pane pid cwd; do
      [ -n "$cwd" ] || cwd="$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p')"
      if [ "$(repo_of "$cwd")" = "$want" ]; then echo "$pane"; break; fi
    done
}

state="${1:-}"

if [ "$state" = seen ]; then
  tmux list-panes -t "$2" -F '#{pane_id}' 2>/dev/null |
    while read -r pane; do
      [ -d "$dir/$pane" ] || continue
      grep -lx done "$dir/$pane"/* 2>/dev/null | while read -r f; do rm -f "$f"; done
      sync_pane "$pane"
    done
  exit 0
fi

input="$(cat)"
session="$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)"
cwd="$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)"
[ -n "$session" ] || exit 0

map="$dir/sessions/$session"
if [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
  pane="$TMUX_PANE"
elif [ -f "$map" ]; then
  pane="$(cat "$map")"
else
  pane="$(dashboard_pane "${cwd:-$PWD}")"
fi
[ -n "$pane" ] || exit 0
mkdir -p "$dir/$pane" "$dir/sessions"
echo "$pane" >"$map"
file="$dir/$pane/$session"

case "$state" in
  working | waiting)
    echo "$state" >"$file"
    ;;
  done)
    # Already looking at it (and it's the only agent there): nothing to flag.
    if [ "$(tmux display -p -t "$pane" '#{&&:#{pane_active},#{&&:#{window_active},#{session_attached}}}')" = 1 ]; then
      rm -f "$file"
    else
      echo done >"$file"
    fi
    ;;
  idle)
    # Esc-interrupted turns never fire Stop; idle_prompt is the only sign the
    # cog is stale. Leave "done"/"waiting" alone.
    grep -qx working "$file" 2>/dev/null && rm -f "$file"
    ;;
  clear)
    rm -f "$file" "$map"
    ;;
  *) exit 0 ;;
esac

sync_pane "$pane" 2>/dev/null
refresh
exit 0
