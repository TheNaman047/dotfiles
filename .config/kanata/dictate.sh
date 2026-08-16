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

# Resolve voxtype to an absolute path *before* dropping privileges. Neither
# caller's PATH can find a user-installed binary: kanata inherits the bare
# service PATH (/usr/bin:/bin:/usr/sbin:/sbin), and sudo re-resolves the
# command name under its own PATH policy rather than the target user's login
# environment. Looking it up here means what we hand to sudo is already a path.
PATH="$(eval echo "~$user")/.local/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"
vox="$(command -v voxtype)" || {
  echo "dictate.sh: voxtype not found on PATH" >&2
  exit 1
}

if [ "$(id -u)" -ne 0 ]; then
  # Already the user (e.g. run by hand, or a non-root kanata build).
  exec "$vox" record toggle
fi

uid="$(id -u "$user")"

case "$(uname)" in
  Darwin)
    exec launchctl asuser "$uid" sudo -u "$user" "$vox" record toggle
    ;;
  *)
    exec sudo -u "$user" env "XDG_RUNTIME_DIR=/run/user/$uid" "$vox" record toggle
    ;;
esac
