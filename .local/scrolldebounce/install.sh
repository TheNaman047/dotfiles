#!/bin/zsh
# Builds scrolldebounce and installs it as a login LaunchAgent. Re-run after editing the source.
# Uninstall: ./install.sh --uninstall
set -e
D=${0:A:h}
P=~/Library/LaunchAgents/local.scrolldebounce.plist
launchctl bootout gui/$(id -u) $P 2>/dev/null || true
[[ $1 == --uninstall ]] && { rm -f $P; echo uninstalled; exit; }
swiftc -O "$D/scrolldebounce.swift" -o "$D/scrolldebounce"
cat > $P <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>local.scrolldebounce</string>
<key>ProgramArguments</key><array><string>$D/scrolldebounce</string></array>
<key>RunAtLoad</key><true/>
<key>KeepAlive</key><true/>
<key>ThrottleInterval</key><integer>10</integer>
<key>StandardErrorPath</key><string>/tmp/scrolldebounce.log</string>
</dict></plist>
PL
launchctl bootstrap gui/$(id -u) $P && echo "installed. If it isn't filtering, add $D/scrolldebounce in Privacy & Security > Accessibility (+ then Cmd-Shift-G), then: launchctl kickstart -k gui/$(id -u)/local.scrolldebounce"
