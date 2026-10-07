#!/usr/bin/env bash
# Fixed project workspaces on prefix+P: pick one, jump to its session if it is
# running, otherwise build it first.
#
# PP_PREFIX prefixes every session name, for dry runs that must not touch the
# real sessions: PP_PREFIX=test- project-picker.sh medlink

set -euo pipefail

PROJECTS=(vidopix medlink coverstar alfa emoney)
P="$HOME/Projects"
# Same as <leader>aa in nvim/lua/plugins/ai.lua: agent view scoped to the cwd.
CLAUDE_NVIM="nvim . -c \"execute 'ClaudeCode agents --cwd ' . shellescape(getcwd())\""

# First window comes with the session; the rest are appended. Each pane gets a
# shell first so quitting nvim drops back to a prompt instead of closing it.
win() {
    local session=$1 name=$2 dir=$3 cmd=$4 pane
    if tmux has-session -t "=$session" 2>/dev/null; then
        pane=$(tmux new-window -d -P -F '#{pane_id}' -t "=$session:" -n "$name" -c "$dir")
    else
        pane=$(tmux new-session -d -P -F '#{pane_id}' -s "$session" -n "$name" -c "$dir")
    fi
    tmux send-keys -t "$pane" "$cmd" Enter
}

build() {
    local s=$1 name=${1#"${PP_PREFIX:-}"}
    case $name in
        vidopix)
            win "$s" backend "$P/ai-emotion/code/ai-emotion-backend" "$CLAUDE_NVIM"
            win "$s" infra "$P/ai-emotion/code/ai-emotion-infra" "$CLAUDE_NVIM"
            ;;
        medlink)
            # Every alfa-medlink-* repo except git worktrees (-wt-), window
            # named after the part past the prefix: admin-api, agents, ...
            local dir
            for dir in "$P"/alfa/code/alfa-medlink-*/; do
                dir=${dir%/}
                [[ $dir == *-wt-* ]] && continue
                win "$s" "${dir##*/alfa-medlink-}" "$dir" "$CLAUDE_NVIM"
            done
            ;;
        coverstar)
            local cs="$P/coverstar/code"
            win "$s" backend "$cs/spotlight-backend" "$CLAUDE_NVIM"
            win "$s" db-dev "$cs/spotlight-backend" "nvim -c 'DBUIConnect spotlight1-pgcat-dev'"
            win "$s" db-prod "$cs/spotlight-backend" "nvim -c 'DBUIConnect spotlight2-pgcat-prod'"
            win "$s" agents "$cs/coverstar-agents" "$CLAUDE_NVIM"
            ;;
        alfa)
            win "$s" iac "$P/alfa/code/alfa-iac" "$CLAUDE_NVIM"
            ;;
        emoney)
            win "$s" code "$P/emoney/code" "$CLAUDE_NVIM"
            ;;
        *)
            tmux display-message "project-picker: unknown project '$name'"
            exit 1
            ;;
    esac
    tmux select-window -t "=$s:^"
}

pick() {
    local p
    for p in "${PROJECTS[@]}"; do
        if tmux has-session -t "=${PP_PREFIX:-}$p" 2>/dev/null; then
            printf '%s\t● running\n' "$p"
        else
            printf '%s\t\n' "$p"
        fi
    done | fzf --margin 10% --color=bw --reverse --header "open project" \
        --delimiter '\t' --with-nth 1,2 | cut -f1
}

project=${1:-$(pick)} || exit 0
[[ -z $project ]] && exit 0

session="${PP_PREFIX:-}$project"
tmux has-session -t "=$session" 2>/dev/null || build "$session"

if [[ -n ${TMUX:-} ]]; then
    tmux switch-client -t "=$session"
elif [[ -z ${PP_PREFIX:-} ]]; then
    exec tmux attach-session -t "=$session"
fi
