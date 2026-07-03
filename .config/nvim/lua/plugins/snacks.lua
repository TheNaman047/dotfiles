vim.pack.add({
  "https://github.com/folke/snacks.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

local Snacks = require("snacks")

Snacks.setup({
  dim = { enabled = false },
  image = { enabled = false },
  indent = { enabled = false },
  notifier = { enabled = true },
  picker = {
    enabled = true,
    matcher = {
      frecency = true,   -- rank frequent/recent files first, like fff
      cwd_bonus = true,  -- boost matches in the current dir
    },
    win = {
      input = {
        keys = {
          -- single Esc closes from both insert and normal mode
          ["<Esc>"] = { "close", mode = { "n", "i" } },
        },
      },
    },
  },
  quickfile = { enabled = false },
  statuscolumn = { enabled = false },
  terminal = { enabled = false },
})

-- stylua: ignore start
local keymaps = {
  { "<leader>gg", function() Snacks.lazygit() end,               desc = "Lazygit" },
  { "<leader>p",  function() Snacks.picker.files() end,          desc = "Find files" },
  { "<leader>l",  function() Snacks.picker.grep() end,           desc = "Live grep" },
  { "<leader>gb", function() Snacks.picker.buffers() end,        desc = "Buffers" },
  { "<leader>sh", function() Snacks.picker.help() end,           desc = "Help" },
  { "<leader>r",  function() Snacks.picker.resume() end,         desc = "Resume picker" },
  {
    "<leader>N",
    desc = "Neovim News",
    function()
      Snacks.win({
        file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
        width = 0.6,
        height = 0.6,
        wo = {
          spell = false,
          wrap = false,
          signcolumn = "yes",
          statuscolumn = " ",
          conceallevel = 3,
        },
      })
    end,
  }
}
-- stylua: ignore end
for _, m in ipairs(keymaps) do
  vim.keymap.set(m.mode or "n", m[1], m[2], { desc = m.desc })
end
