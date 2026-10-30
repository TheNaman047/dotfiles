#!/usr/bin/env bash
# Stop Claude Code background sessions that have sat idle for a while, so they
# (and their MCP servers) stop holding RAM. Run from launchd every 30 min.
#
#   claude-reap-idle.sh [--dry-run]
#
# A session is reaped when it is a background session, not busy, and its job
# state hasn't changed for CLAUDE_REAP_IDLE_HOURS (default 3). `claude stop`
# keeps the conversation: `claude attach <id>` brings it back.

PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/bin:/bin"
idle_secs=$(( ${CLAUDE_REAP_IDLE_HOURS:-3} * 3600 ))
dry_run=0; [ "$1" = "--dry-run" ] && dry_run=1
now=$(date +%s)

claude agents --json 2>/dev/null |
  jq -r '.[] | select(.kind == "background" and .status != "busy")
         | [.id, .startedAt, .name // ""] | @tsv' |
  while IFS=$'\t' read -r id started name; do
    # state.json is rewritten on every state change; startedAt covers jobs without one.
    last=$(stat -f %m "$HOME/.claude/jobs/$id/state.json" 2>/dev/null || echo $(( started / 1000 )))
    (( now - last < idle_secs )) && continue
    echo "$(date '+%F %T') stop $id ($(( (now - last) / 3600 ))h idle) $name"
    (( dry_run )) || claude stop "$id" >/dev/null 2>&1
  done
