#!/usr/bin/env bash
# Toggle voxtype dictation, invoked from kanata, on both Linux and macOS.
#
# Why this wrapper exists: kanata runs as root on both platforms (a systemd
# system service on Linux, and root for the Karabiner virtual HID driver on
# macOS), but the voxtype daemon is per-user. A bare `voxtype record toggle`
# from root looks at root's config and runtime dir and silently does nothing
# to your session, so we always drop back to the desktop user first.
#
# The two platforms need different re-entry into the user session:
#   Linux -- the daemon socket lives in $XDG_RUNTIME_DIR (/run/user/<uid>),
#            which sudo does not set for us.
#   macOS -- the daemon is a launchd *user agent*, so the call has to be made
#            inside that user's bootstrap namespace via `launchctl asuser`.

set -euo pipefail

user="thenaman047"

if [ "$(id -u)" -ne 0 ]; then
  # Already the user (e.g. run by hand, or a non-root kanata build).
  exec voxtype record toggle
fi

uid="$(id -u "$user")"

case "$(uname)" in
  Darwin)
    exec launchctl asuser "$uid" sudo -u "$user" voxtype record toggle
    ;;
  *)
    exec sudo -u "$user" env "XDG_RUNTIME_DIR=/run/user/$uid" voxtype record toggle
    ;;
esac
