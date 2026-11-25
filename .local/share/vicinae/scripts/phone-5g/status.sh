#!/bin/bash
# @vicinae.schemaVersion 1
# @vicinae.title Phone 5G: Status
# @vicinae.mode fullOutput
# @vicinae.icon 📶
# @vicinae.keywords ["phone", "5g", "airtel", "hotspot", "sim"]
# @vicinae.description Watchdog status and recent log
$HOME/.local/bin/p5g status; echo; $HOME/.local/bin/p5g log 15
