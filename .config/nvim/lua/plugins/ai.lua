vim.pack.add({
  "https://github.com/olimorris/codecompanion.nvim",
  "https://github.com/ravitemer/codecompanion-history.nvim",
  "https://github.com/coder/claudecode.nvim",
  "https://github.com/NickvanDyke/opencode.nvim",
})

-- OpenCode config
local opencode_cmd = 'opencode --port'

local Terminal = require('toggleterm.terminal').Terminal

local opencode_term = Terminal:new({
  cmd = opencode_cmd,
  direction = 'vertical', -- or 'float', 'horizontal'
  hidden = true,
  on_open = function(term)
    -- Mirror snacks' on_win callback using toggleterm's window id
    require('opencode.terminal').setup(term.window)
  end,
})

---@type opencode.Opts
vim.g.opencode_opts = {
  server = {
    start = function()
      opencode_term:open()
    end,
    stop = function()
      opencode_term:close()
    end,
    toggle = function()
      opencode_term:toggle()
    end,
  },
}

-- require "claudecode".setup({
--   terminal = {
--     provider = "none", -- no UI actions; server + tools remain available
--   },
-- })

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

-- ClaudeCode
-- vim.keymap.set("n", "<leader>c", "<cmd>ClaudeCode<cr>", opts)
-- vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", opts)
-- vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", opts)

-- OpenCode
vim.keymap.set({ "n", "x" }, "<leader>ea", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
vim.keymap.set({ "n", "x" }, "<leader>ex", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
vim.keymap.set({ "n" }, "<leader>k", function() require("opencode").toggle() end,                          { desc = "Toggle opencode" })

vim.keymap.set({ "n", "x" }, "<leader>er",  function() return require("opencode").operator("@this ") end,        { desc = "Add range to opencode", expr = true })
vim.keymap.set("n",          "<leader>ef", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })

vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,   { desc = "Scroll opencode up" })
vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll opencode down" })

-- Code Companion keymaps
vim.keymap.set({ "n", "v" }, "<leader>i", "<cmd>CodeCompanionChat Toggle<cr>", opts)
vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", opts)
vim.keymap.set({ "n", "v" }, "<leader>ah", "<cmd>CodeCompanionHistory<cr>", opts)
vim.keymap.set("v", "<leader>ap", "<cmd>CodeCompanionChat Add<cr>", opts)
