#!/usr/bin/env bash
# Assert every theme key leaves Normal with no background, i.e. transparency actually took.
# Run after adding a theme to set-theme.sh + nvim/lua/plugins/theme.lua - each plugin
# spells its transparency option differently, so a wrong name silently no-ops.
set -uo pipefail

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="$(dirname "$THEME_DIR")"
# theme.lua reads ~/.config/theme/current by absolute path, so drive the real one and put it back
CUR="$HOME/.config/theme/current"
SAVED="$(cat "$CUR")"
trap 'echo "$SAVED" >"$CUR"' EXIT

fail=0
for key in $("$THEME_DIR/set-theme.sh" --list | cut -f1); do
  echo "$key" >"$CUR"
  out=$(XDG_CONFIG_HOME="$CONFIG_ROOT" nvim --headless \
    "+lua local n=vim.api.nvim_get_hl(0,{name='Normal'}) print(vim.g.colors_name..' bg='..tostring(n.bg))" \
    +q 2>&1 | tail -1)
  case "$out" in
  *"bg=nil"*) echo "ok   $key -> $out" ;;
  *)
    echo "FAIL $key -> $out"
    fail=1
    ;;
  esac
done

# tmux is the other place a background gets painted: ukiyo's window-style would
# cover ghostty's blur for every pane. Scratch socket, so a running server is untouched.
# ukiyo lives in a submodule that a bare worktree does not check out, so use the
# installed copy - and fail loudly rather than passing because it never ran.
UKIYO="$HOME/.config/tmux/plugins/tmux-ukiyo/scripts/ukiyo.sh"
if [ ! -x "$UKIYO" ]; then
  echo "FAIL tmux panes -> $UKIYO missing, cannot verify"
  fail=1
else
  tmux -L transparency-check kill-server 2>/dev/null
  tmux -L transparency-check -f /dev/null new-session -d -x 80 -y 24
  # seed the opaque value ukiyo used to set, so a pass proves it was actually cleared
  tmux -L transparency-check set-window-option -g window-style "fg=#ffffff,bg=#161616"
  tmux -L transparency-check source-file "$CONFIG_ROOT/tmux/tmux.ukiyo.conf"
  tmux -L transparency-check run-shell "$UKIYO"
  sleep 1
  style=$(tmux -L transparency-check show-window-options -gv window-style)
  status=$(tmux -L transparency-check show-options -gv status-style)
  tmux -L transparency-check kill-server 2>/dev/null
  if [ "$style" = "default" ] && [ -n "$status" ]; then
    echo "ok   tmux panes -> window-style=$style (status bar keeps $status)"
  else
    echo "FAIL tmux panes -> window-style=$style status-style=$status"
    fail=1
  fi
fi

exit $fail
