#!/bin/bash
# Build the applet Finicky opens for Notion links. Re-run after editing the
# .applescript; macOS asks once to let it control Brave.

set -e
src="$(cd "$(dirname "$0")" && pwd)/notion-router.applescript"
app="$HOME/.local/share/finicky/NotionRouter.app"

mkdir -p "$(dirname "$app")"
rm -rf "$app"
osacompile -o "$app" "$src"
# Background-only: no Dock icon flashing on every link.
plutil -replace LSUIElement -bool true "$app/Contents/Info.plist"
plutil -replace CFBundleIdentifier -string com.naman.notion-router "$app/Contents/Info.plist"
codesign --force --sign - "$app"
echo "built $app"
