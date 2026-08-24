#!/usr/bin/env bash
# Fuzzy-pick a Claude session — background agent or interactive REPL — scoped to
# the current window's directory, and open it in this window.
#
# This replaces the `claude agents --cwd $PWD` split. Neither built-in view shows
# both kinds: the `claude agents` TUI lists background agents only, and
# tmux-claude-session-manager listed interactive ones only. `claude agents
# --json` is the sole source that reports both, so this joins them.
#
# With the global `tui: "fullscreen"` setting, anything started from Claude's
# home screen becomes a *background* agent — interactive rows appear only for a
# plain REPL (`tui: "default"`, or `claude` in a bare terminal). So in practice
# this list is mostly background agents, which is the point.
#
# A window holds one agent pane. Picking an agent swaps it into the pane already
# open, respawned in place, and splits a new one only when this window has no
# agent pane yet — so you cycle through sessions in the pane you are already
# looking at, rather than accumulating panes, windows or popups. That the reuse
# is per *window* and not per cwd is deliberate: one agent per git worktree is
# normal here, so two agents in one project usually have different cwds, and
# keying on cwd alone would split a fresh pane for each. An agent already
# attached somewhere is jumped to instead of being opened twice. The only thing
# in a popup is this picker.
#
# Pane width on first split comes from CC_SPLIT (default 65%).
#
#   claude-picker.sh --popup <client> <window> <path>
#                                               what the tmux binding calls: opens
#                                               the picker in a popup on <client>
#   claude-picker.sh <client> <window> <path>   pick (inside that popup)
#   claude-picker.sh --list [path]              rows only; no path = every session
#   claude-picker.sh --open <client> <window> <id> <pane> <cwd> [pane-cwd]
#                                               open one row without the picker
#   claude-picker.sh --preview <kind> <pane> <session-id>

set -uo pipefail

# Bare `claude` resolves to ~/.local/bin/claude, whose `mise x` hand-off spins at
# ~41% CPU and never renders a TUI when started from tmux's bare env. Use the
# binary directly; `latest` is a symlink mise repoints on upgrade.
CLAUDE="${CLAUDE_BIN:-$HOME/.local/share/mise/installs/claude/latest/claude}"
[ -x "$CLAUDE" ] || CLAUDE=claude

SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

# Width of the agent pane, used only the first time one is created for a
# directory. Every later pick reuses that pane, so this size is set once.
CC_SPLIT="${CC_SPLIT:-65%}"

parent=''   # tmux client to move; empty means "the default client"
window=''   # window that owns the agent pane
pane_cwd='' # start directory for the agent pane: the directory the picker was
            # invoked from, NOT the agent's own cwd. `claude attach` carries the
            # session's directory itself, so the pane's cwd is free — and it has
            # to stay at the invoking directory, because the next prefix+u run
            # from inside this pane reads #{pane_current_path} as its scope. Set
            # it to a worktree and the scope collapses to that one agent.

# ---------------------------------------------------------------- rows --------
# rows [scope-path]  — with a scope, only sessions at or under that path.
rows() {
  local scope="${1:-}" agents
  agents="$("$CLAUDE" agents --json 2>/dev/null)" || return 0
  [ -n "$agents" ] || return 0

  # Three tagged streams into one awk: pid->tty, tty->pane, then the agents.
  # The pid->tty->pane join locates an interactive REPL's pane; a background
  # agent has no tty and simply skips it.
  {
    ps -Ao pid=,tty= 2>/dev/null | awk '{ print "P\t" $1 "\t" $2 }'
    tmux list-panes -a -F $'T\t#{pane_tty}\t#{pane_id}' 2>/dev/null
    printf '%s' "$agents" | jq -r '
      .[] | ["A", .kind, .id, (.pid // ""), (.state // .status // ""),
             (.cwd // ""), (.name // ""), (.sessionId // "")] | @tsv' 2>/dev/null
  } | awk -F'\t' -v home="$HOME" -v scope="$scope" '
    $1 == "P" { tty_of[$2] = $3; next }
    $1 == "T" { sub(/^\/dev\//, "", $2); pane_of[$2] = $3; next }
    $1 == "A" {
      kind = $2; id = $3; pid = $4; state = $5; cwd = $6; name = $7; sid = $8

      # Scope is a prefix match, so a worktree under the project still counts.
      if (scope != "" && cwd != scope && index(cwd, scope "/") != 1) next

      pane = "-"
      if (pid != "" && (pid in tty_of) && (tty_of[pid] in pane_of))
        pane = pane_of[tty_of[pid]]

      # Needs-you states float to the top; busy ones sink.
      if (state == "blocked" || state == "waiting")   { disp = "\033[33m●\033[0m needs input"; rank = 0 }
      else if (state == "done" || state == "idle")    { disp = "\033[32m●\033[0m done       "; rank = 1 }
      else if (state == "working" || state == "busy") { disp = "\033[31m●\033[0m working    "; rank = 3 }
      else                                            { disp = "\033[90m●\033[0m ?          "; rank = 2 }

      kd = (kind == "interactive") ? "\033[36mrepl\033[0m" : "\033[35m bg \033[0m"

      short = cwd
      if (index(short, home) == 1) short = "~" substr(short, length(home) + 1)
      if (name == "") name = "(unnamed)"
      if (length(name) > 44) name = substr(name, 1, 43) "…"

      printf "%s\t%s\t%s\t%s\t%s\t%s\t%-44s\t%s\t%s\t%s\n",
        rank, kind, id, pane, disp, kd, name, short, cwd, sid
    }
  ' | sort -t$'\t' -k1,1n
}

# ---------------------------------------------------------------- open --------
# switch_to <pane-or-window> — move the client that opened this picker there.
switch_to() {
  local sess
  sess="$(tmux display-message -p -t "$1" '#{session_name}' 2>/dev/null)" || return 1
  [ -n "$sess" ] || return 1
  if [ -n "$parent" ]; then
    tmux switch-client -c "$parent" -t "$sess" 2>/dev/null
  else
    tmux switch-client -t "$sess" 2>/dev/null
  fi
  tmux select-window -t "$1" 2>/dev/null
}

# open_row <id> <pane> <cwd>
open_row() {
  local id="$1" pane="$2" cwd="$3" attached slot

  # An interactive REPL already lives in a pane — just go there.
  if [ "$pane" != '-' ] && [ -n "$pane" ]; then
    switch_to "$pane" && tmux select-pane -t "$pane" 2>/dev/null
    return
  fi

  # Already attached somewhere? Jump to that pane instead of attaching twice.
  attached="$(tmux list-panes -a -F '#{pane_id}	#{@cc_agent}' 2>/dev/null |
    awk -F'\t' -v id="$id" '$2 == id { print $1; exit }')"
  if [ -n "$attached" ]; then
    switch_to "$attached" && tmux select-pane -t "$attached" 2>/dev/null
    return
  fi

  [ -d "$cwd" ] || cwd="$HOME"
  [ -n "$window" ] || window="$(tmux display-message -p '#{window_id}' 2>/dev/null)"

  # Where the pane itself sits — see the pane_cwd comment at the top. Falls back
  # to the agent's own directory only when the invoking one is unusable.
  local start="$pane_cwd"
  [ -n "$start" ] && [ -d "$start" ] || start="$cwd"

  # Find the pane to swap this agent into, preferring, in order:
  #   1. this window's pane for the same cwd
  #   2. that cwd's pane in another window — go to where that project lives
  #   3. any agent pane in this window, whatever cwd it holds
  # (3) is what makes cycling work in practice: one agent per git worktree is
  # normal here, so two agents in the same project usually have *different*
  # cwds, and keying on cwd alone would split a second pane for each one.
  # Only when this window has no agent pane at all do we split a new one.
  slot="$(tmux list-panes -a -F '#{pane_id}	#{window_id}	#{@cc_cwd}' 2>/dev/null |
    awk -F'\t' -v cwd="$cwd" -v w="$window" '
      # An untagged pane has an empty tag; skipping those keeps a pane holding
      # unrelated work from being respawned out from under you.
      $3 == "" { next }
      {
        if ($3 == cwd) {
          if ($2 == w) here_exact = $1
          else if (!other_exact) other_exact = $1
        }
        if ($2 == w && !here_any) here_any = $1
      }
      END {
        if (here_exact)       print here_exact
        else if (other_exact) print other_exact
        else if (here_any)    print here_any
      }')"

  if [ -n "$slot" ]; then
    tmux respawn-pane -k -t "$slot" -c "$start" "$CLAUDE attach '$id'" 2>/dev/null
  else
    slot="$(tmux split-window -h -l "$CC_SPLIT" -t "$window" -c "$start" \
      -P -F '#{pane_id}' "$CLAUDE attach '$id'" 2>/dev/null)"
  fi

  [ -n "$slot" ] || return 1
  tmux set-option -p -t "$slot" @cc_agent "$id" 2>/dev/null
  tmux set-option -p -t "$slot" @cc_cwd "$cwd" 2>/dev/null
  switch_to "$slot" && tmux select-pane -t "$slot" 2>/dev/null
}

# ------------------------------------------------------------ dispatch --------
case "${1:-}" in
--preview)
  pane="${3:-}"; sid="${4:-}"
  if [ "$pane" != '-' ] && [ -n "$pane" ]; then
    tmux capture-pane -ept "$pane" 2>/dev/null
    exit 0
  fi
  # `claude logs` replays the agent's raw terminal output — full-screen redraws
  # and cursor escapes that are unreadable in a preview pane. The transcript is
  # plain JSONL, so read the conversation out of that instead.
  f=''
  [ -n "$sid" ] && f="$(ls "$HOME"/.claude/projects/*/"$sid".jsonl 2>/dev/null | head -1)"
  if [ -n "$f" ] && [ -r "$f" ]; then
    jq -r 'select(.type == "user" or .type == "assistant")
      | (.message.content) as $c
      | (if ($c | type) == "string" then $c
         else ([$c[]? | select(.type == "text") | .text] | join("\n")) end) as $t
      | select($t != null and ($t | length) > 0)
      | select($t | test("^\\s*<(command-|local-command)") | not)
      | "\(if .type == "user" then "❯" else "●" end) \($t)"' "$f" 2>/dev/null |
      cut -c1-400 | tail -60
  else
    echo '(no transcript yet)'
  fi
  exit 0
  ;;
--list)
  rows "${2:-}"
  exit 0
  ;;
--open)
  parent="${2:-}"; window="${3:-}"; pane_cwd="${7:-}"
  open_row "${4:-}" "${5:--}" "${6:-$HOME}"
  exit $?
  ;;
--popup)
  # The binding routes through `run-shell` because display-popup does NOT expand
  # formats in its shell-command (nor in -e) — only -d is expanded, and
  # `display-message` run inside a popup reports whichever client was last
  # active, not the one that opened it. run-shell does expand them, so the
  # client, window and path are resolved here and passed in explicitly.
  cmd="$(printf '%q %q %q %q' "$SELF" "${2:-}" "${3:-}" "${4:-}")"
  if [ -n "${2:-}" ]; then
    tmux display-popup -c "$2" -w 80% -h 70% -E "$cmd"
  else
    tmux display-popup -w 80% -h 70% -E "$cmd"
  fi
  exit 0
  ;;
esac

# ---------------------------------------------------------------- pick --------
for tool in fzf jq; do
  command -v "$tool" >/dev/null 2>&1 || {
    tmux display-message "claude-picker: $tool is required"
    exit 0
  }
done

parent="${1:-}"
window="${2:-}"
scope="${3:-$PWD}"
scope="${scope%/}"
pane_cwd="$scope"   # keep it even if scope is later widened to all

short_scope="$scope"
[ "${short_scope#$HOME/}" != "$short_scope" ] && short_scope="~${short_scope#$HOME}"

listing="$(rows "$scope")"
if [ -z "$listing" ]; then
  # Nothing here — fall back to every session rather than an empty popup.
  listing="$(rows)"
  [ -n "$listing" ] || {
    tmux display-message 'claude-picker: no Claude sessions running'
    exit 0
  }
  # No parentheses here: this string goes inside fzf's change-header(...) action,
  # whose argument is delimited by matching parens.
  short_scope="all · nothing under $short_scope"
  scope=''
fi

export FZF_DEFAULT_OPTS=''
hdr="Claude · $short_scope · enter open · ^x stop · ^a all · ^s this dir"
sel="$(printf '%s\n' "$listing" | fzf --ansi --delimiter='\t' --with-nth=5,6,7,8 \
  --reverse --cycle --header="$hdr" \
  --preview="$SELF --preview {2} {4} {10}" --preview-window='up,65%,follow' \
  --bind="ctrl-x:execute-silent($CLAUDE stop {3})+reload(sleep 0.4; $SELF --list '$scope')" \
  --bind="ctrl-a:reload($SELF --list)+change-header(Claude · all sessions · enter open · ^x stop · ^s this dir)" \
  --bind="ctrl-s:reload($SELF --list '$scope')+change-header($hdr)")"

[ -z "$sel" ] && exit 0

open_row "$(printf '%s' "$sel" | cut -f3)" \
         "$(printf '%s' "$sel" | cut -f4)" \
         "$(printf '%s' "$sel" | cut -f9)"
