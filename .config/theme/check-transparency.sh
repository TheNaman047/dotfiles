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
exit $fail
