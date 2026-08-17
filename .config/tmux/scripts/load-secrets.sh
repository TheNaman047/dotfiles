#!/bin/bash
# Runs once per tmux server start (sourced synchronously from tmux.conf), instead of
# once per pane/window/session via ~/.zprofile. Pushes results into tmux's global
# environment, which every new pane/window/session inherits automatically.
eval "$(keychain --eval --quiet EE2DB02E3E10E2D32B047BE3BDB0B8BD5D292AC0)"

tmux set-environment -g SSH_AUTH_SOCK "$SSH_AUTH_SOCK"
tmux set-environment -g SSH_AGENT_PID "$SSH_AGENT_PID"
tmux set-environment -g MISTRAL_API_KEY "$(gopass personal/mistral_api_key)"
tmux set-environment -g ANTHROPIC_API_KEY "$(gopass coverstar/anthropic_api_key)"
tmux set-environment -g GROQ_API_KEY "$(gopass personal/groq_api_key)"
tmux set-environment -g HF_TOKEN "$(gopass personal/hf_token)"
