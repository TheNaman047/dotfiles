vim.pack.add({
  "https://github.com/coder/claudecode.nvim",
  "https://github.com/NickvanDyke/opencode.nvim",
})

-- OpenCode config
vim.g.opencode_opts = {}

-- "none": no in-editor terminal; run `claude` in a tmux/herdr pane and attach with /ide
require("claudecode").setup({
  terminal = { provider = "none" },
  diff_opts = {
    layout = "vertical",
    open_in_new_tab = false,
  },
})

local function cc(desc) return { noremap = true, silent = true, desc = desc } end

vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", cc("Claude: add current file"))
vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", cc("Claude: send selection"))
vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", cc("Claude: accept diff"))
vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", cc("Claude: deny diff"))
vim.keymap.set("n", "<leader>aq", "<cmd>ClaudeCodeCloseAllDiffs<cr>", cc("Claude: close all diffs"))

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("claudecode_tree", { clear = true }),
  pattern = "oil",
  callback = function(args)
    vim.keymap.set({ "n", "v" }, "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>",
      { buffer = args.buf, noremap = true, silent = true, desc = "Claude: add file(s)" })
  end,
})

-- OpenCode
vim.keymap.set({ "n", "x" }, "<leader>ea", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
vim.keymap.set({ "n", "x" }, "<leader>ex", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
vim.keymap.set({ "n", "x" }, "<leader>er",  function() return require("opencode").operator("@this ") end,        { desc = "Add range to opencode", expr = true })
vim.keymap.set("n",          "<leader>ef", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })
