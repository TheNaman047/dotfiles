#!/usr/bin/env bash
# Render a PNG in this pane, re-rendering whenever the file changes.
# Driven by nvim's <leader>mt (lua/plugins/typst.lua), which compiles the PNG.
set -euo pipefail

png=${1:?usage: typst-preview-pane.sh <png>}

# Ghostty speaks the kitty graphics protocol; tmux needs the DCS wrapper
# (--passthrough) plus `allow-passthrough on` to let it reach the terminal.
render() {
  clear
  chafa -f kitty --passthrough tmux "$png" 2>/dev/null ||
    printf 'waiting for %s\n' "$png"
}

# ponytail: mtime poll, no watcher dependency. Switch to fswatch if 0.3s lags.
last=
while :; do
  now=$(stat -f %m "$png" 2>/dev/null || echo "")
  if [ "$now" != "$last" ]; then
    last=$now
    render
  fi
  sleep 0.3
done
