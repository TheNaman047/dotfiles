vim.pack.add({
  "https://github.com/coder/claudecode.nvim",
  "https://github.com/NickvanDyke/opencode.nvim",
})

-- OpenCode config
vim.g.opencode_opts = {}

require("claudecode").setup({
  -- native = plain :terminal split, no snacks dependency
  terminal = {
    provider = "native",
    split_side = "right",
    split_width_percentage = 0.4,
    auto_close = true,
  },
  focus_after_send = false,
  diff_opts = {
    layout = "vertical",
    open_in_new_tab = false,
    keep_terminal_focus = false,
    hide_terminal_in_new_tab = false,
  },
})

-- OpenCode
vim.keymap.set({ "n", "x" }, "<leader>ea", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
vim.keymap.set({ "n", "x" }, "<leader>ex", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
vim.keymap.set({ "n", "x" }, "<leader>er",  function() return require("opencode").operator("@this ") end,        { desc = "Add range to opencode", expr = true })
vim.keymap.set("n",          "<leader>ef", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })
