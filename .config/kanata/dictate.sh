#!/usr/bin/env bash
# Toggle voxtype dictation, from kanata, on both Linux and macOS.
#
# Why this wrapper exists: on Linux kanata runs as a root systemd *system*
# service, but the voxtype daemon is a per-user service whose socket lives in
# $XDG_RUNTIME_DIR (/run/user/<uid>). A bare `voxtype record toggle` from root
# looks for /root/.config + /run/user/0 and silently does nothing to your
# session, so we drop privileges back to the desktop user first.
#
# On macOS kanata already runs as the logged-in user and voxtype is a launchd
# user agent, so the plain call is correct there.

set -euo pipefail

user="thenaman047"

if [ "$(uname)" = "Linux" ] && [ "$(id -u)" -eq 0 ]; then
  uid="$(id -u "$user")"
  exec sudo -u "$user" env "XDG_RUNTIME_DIR=/run/user/$uid" voxtype record toggle
fi

exec voxtype record toggle
