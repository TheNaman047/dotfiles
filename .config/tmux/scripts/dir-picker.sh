#!/usr/bin/env bash
# Browse project directories and open one as a sesh session.
#
# `prefix s` lists only what's already running or configured; this is the other
# half — reaching a repo you haven't opened yet. Session naming, reuse and the
# startup command all come from sesh, so this only has to pick a path.
#
# Optional arg scopes the search to one root, e.g. dir-picker.sh ~/Projects/alfa

set -euo pipefail

if [[ $# -eq 1 ]]; then
    candidates=$(fd . "$1" --type=dir --max-depth=3 --full-path)
else
    # fd finds repos never visited; zoxide surfaces the ones used most.
    candidates=$(
        fd . "$HOME/Projects" --type=dir --max-depth=3 --full-path
        fd . "$HOME/dotfiles/.config" --type=dir --max-depth=1 --full-path
        zoxide query --list 2>/dev/null | head -20
    )
fi

selected=$(
    printf '%s\n' "$candidates" \
        | sed -e 's|/$||' -e "s|^$HOME/|~/|" \
        | awk 'NF && !seen[$0]++' \
        | fzf --margin 10% --color=bw --reverse --header "open directory"
) || exit 0

[[ -z $selected ]] && exit 0

exec sesh connect "${selected/#\~\//$HOME/}"
