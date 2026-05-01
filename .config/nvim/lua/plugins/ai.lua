vim.pack.add({
  "https://github.com/olimorris/codecompanion.nvim",
  "https://github.com/ravitemer/codecompanion-history.nvim",
  "https://github.com/NickvanDyke/opencode.nvim",
})

local opts = { noremap = true, silent = true }

-- OpenCode config
vim.g.opencode_opts = {}

require "codecompanion".setup({
  display = { chat = { window = { width = 0.4, } } },
  strategies = {
    chat = {
      adapter = "anthropic",
      model = "claude-sonnet-4.6",
      auto_scroll = false,
    },
  },
  extensions = { history = { enabled = true } }
})

-- OpenCode
vim.keymap.set({ "n", "x" }, "<leader>ea", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
vim.keymap.set({ "n", "x" }, "<leader>ex", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
vim.keymap.set({ "n", "x" }, "<leader>er",  function() return require("opencode").operator("@this ") end,        { desc = "Add range to opencode", expr = true })
vim.keymap.set("n",          "<leader>ef", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })

-- Code Companion keymaps
vim.keymap.set({ "n", "v" }, "<leader>i", "<cmd>CodeCompanionChat Toggle<cr>", opts)
vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", opts)
vim.keymap.set({ "n", "v" }, "<leader>ah", "<cmd>CodeCompanionHistory<cr>", opts)
vim.keymap.set("v", "<leader>ap", "<cmd>CodeCompanionChat Add<cr>", opts)
