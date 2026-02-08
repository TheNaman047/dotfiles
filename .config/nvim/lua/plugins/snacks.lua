vim.pack.add({
"https://github.com/folke/snacks.nvim",
"https://github.com/nvim-tree/nvim-web-devicons",
})

local Snacks = require("snacks")

Snacks.setup({
  dim = { enabled = true },
  image = { enabled = true },
  indent = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  terminal = { enabled = true },
})

-- stylua: ignore start
local keymaps = {
    -- terminal
    { "<leader>t", function() Snacks.terminal() end, desc = "Terminal (cwd)", mode = "n", },
    { "<c-_>", function() Snacks.terminal(nil, { cwd = vim.fn.getcwd() }) end, desc = "which_key_ignore",  mode = "n", },
    -- Other
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
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
for _, map in ipairs(keymaps) do
  local opts = { desc = map.desc }
  if map.silent ~= nil then
    opts.silent = map.silent
  end
  if map.noremap ~= nil then
    opts.noremap = map.noremap
  else
    opts.noremap = true
  end
  if map.expr ~= nil then
    opts.expr = map.expr
  end

  local mode = map.mode or "n"
  vim.keymap.set(mode, map[1], map[2], opts)
end

