-- Rex config migrated from tmux, Herdr, Ghostty and kitty.

-- cmd+k clears the terminal; the session picker is on ctrl+s>s (tmux style).
rex.bind("cmd+k", "com.superlogical.terminal.clear")

-- Drop Rex's cmd-based split/focus/zoom defaults (clash with AeroSpace); use the ctrl+s prefix bindings.
for _, key in ipairs({
  "cmd+d", "shift+cmd+d", "shift+cmd+right", "shift+cmd+down", "shift+cmd+left", "shift+cmd+up", "cmd+enter",
  "alt+cmd+left", "alt+cmd+right", "alt+cmd+up", "alt+cmd+down",
  "shift+cmd+enter",
}) do
  rex.unbind(key)
end

-- vim-tmux-navigator style pane focus, no prefix
rex.bind("ctrl+h", "pane.focus", { direction = "left" })
rex.bind("ctrl+j", "pane.focus", { direction = "down" })
rex.bind("ctrl+k", "pane.focus", { direction = "up" })
rex.bind("ctrl+l", "pane.focus", { direction = "right" })

-- tmux (prefix ctrl+s)
rex.bind("ctrl+s>ctrl+s", "pane.send_key", { key = "ctrl+s" })
rex.bind("ctrl+s>h", "pane.focus", { direction = "left" })
rex.bind("ctrl+s>j", "pane.focus", { direction = "down" })
rex.bind("ctrl+s>k", "pane.focus", { direction = "up" })
rex.bind("ctrl+s>l", "pane.focus", { direction = "right" })
rex.bind("ctrl+s>shift+h", "pane.resize", { amount = 5, direction = "left" })
rex.bind("ctrl+s>shift+l", "pane.resize", { amount = 5, direction = "right" })
rex.bind("ctrl+s>shift+j", "pane.resize", { amount = 5, direction = "down" })
rex.bind("ctrl+s>shift+k", "pane.resize", { amount = 5, direction = "up" })
rex.bind("ctrl+s>ctrl+x", "pane.close")
rex.bind("ctrl+s>ctrl+f", "pane.zoom")
rex.bind("ctrl+s>shift+b", "pane.move_to_new_tab")
rex.bind("ctrl+s>o", "pane.split", { direction = "right" })
rex.bind("ctrl+s>i", "pane.split", { direction = "right" })
rex.bind("ctrl+s>\\", "pane.split", { direction = "right" })
rex.bind("ctrl+s>-", "pane.split", { direction = "down" })
rex.bind("ctrl+s>c", "client.tab.new")
rex.bind("ctrl+s>ctrl+r", "client.tab.rename")
rex.bind("ctrl+s>b", "session.new")

-- tmux repeatable bindings (bind -r): ctrl+s alt+r enters, enter/escape leaves
rex.mode("repeat", { exclusive = true })
rex.bind("ctrl+s>alt+r", "client.mode.enter", { name = "repeat" })
rex.bind("repeat/enter", "client.mode.exit")
rex.bind("repeat/escape", "client.mode.exit")
rex.bind("repeat/h", "pane.focus", { direction = "left" })
rex.bind("repeat/j", "pane.focus", { direction = "down" })
rex.bind("repeat/k", "pane.focus", { direction = "up" })
rex.bind("repeat/l", "pane.focus", { direction = "right" })
rex.bind("repeat/shift+h", "pane.resize", { amount = 5, direction = "left" })
rex.bind("repeat/shift+l", "pane.resize", { amount = 5, direction = "right" })
rex.bind("repeat/shift+j", "pane.resize", { amount = 5, direction = "down" })
rex.bind("repeat/shift+k", "pane.resize", { amount = 5, direction = "up" })
rex.bind("repeat/b", "session.new")

-- Herdr (prefix ctrl+s)
rex.bind("ctrl+s>r", "client.config.reload")
rex.bind("ctrl+s>,", "client.settings")
rex.bind("ctrl+s>v", "pane.split", { direction = "right" })
rex.bind("ctrl+s>shift+p", "pane.rename")
rex.bind("ctrl+s>tab", "pane.focus_next")
rex.bind("ctrl+s>shift+tab", "pane.focus_previous")
rex.bind("ctrl+s>ctrl+k", "client.tab.previous")
rex.bind("ctrl+s>ctrl+j", "client.tab.next")
rex.bind("ctrl+s>shift+x", "client.tab.close")
rex.bind("ctrl+s>1", "client.tab.goto", { index = 1 })
rex.bind("ctrl+s>2", "client.tab.goto", { index = 2 })
rex.bind("ctrl+s>3", "client.tab.goto", { index = 3 })
rex.bind("ctrl+s>4", "client.tab.goto", { index = 4 })
rex.bind("ctrl+s>5", "client.tab.goto", { index = 5 })
rex.bind("ctrl+s>6", "client.tab.goto", { index = 6 })
rex.bind("ctrl+s>7", "client.tab.goto", { index = 7 })
rex.bind("ctrl+s>8", "client.tab.goto", { index = 8 })
rex.bind("ctrl+s>9", "client.tab.goto", { index = 9 })
rex.bind("ctrl+s>s", "session.switch")
rex.bind("ctrl+s>t", "client.sidebar.toggle")
rex.bind("ctrl+s>shift+w", "session.rename")
rex.bind("ctrl+s>shift+d", "session.close")
rex.bind("ctrl+s>ctrl+g", "session.switch")

-- Herdr resize mode: ctrl+s shift+r enters, enter/escape leaves
rex.mode("resize", { exclusive = true })
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/escape", "client.mode.exit")
rex.bind("ctrl+s>shift+r", "client.mode.enter", { name = "resize" })
rex.bind("resize/left", "pane.resize", { direction = "left" })
rex.bind("resize/down", "pane.resize", { direction = "down" })
rex.bind("resize/up", "pane.resize", { direction = "up" })
rex.bind("resize/right", "pane.resize", { direction = "right" })

-- Ghostty
rex.bind("alt+cmd+r", "client.config.reload")
