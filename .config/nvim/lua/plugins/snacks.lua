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
  picker = { enabled = true },
  quickfile = { enabled = false },
  statuscolumn = { enabled = false },
  terminal = { enabled = false },
})

-- stylua: ignore start
local keymaps = {
  { "<leader>gg", function() Snacks.lazygit() end,               desc = "Lazygit" },
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
