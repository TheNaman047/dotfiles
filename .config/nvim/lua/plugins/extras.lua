vim.pack.add({
  "https://github.com/christoomey/vim-tmux-navigator",
  "https://github.com/ibhagwan/smartyank.nvim",
  "https://github.com/smithbm2316/centerpad.nvim",
  "https://github.com/adriankarlen/plugin-view.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/vuki656/package-info.nvim",
})

require "plugin-view".setup({})
require "package-info".setup({})
require "smartyank".setup()

-- Plugin View keymaps
vim.keymap.set("n", "<leader>v", require("plugin-view").open, opts)

-- Centerpad keymap
vim.keymap.set('n', '<leader>z', '<cmd>Centerpad<cr>', opts)

-- Package Info keymap
vim.keymap.set('n', '<leader>ns', '<cmd>lua require("package-info").show()<cr>', opts)
vim.keymap.set('n', '<leader>np', '<cmd>lua require("package-info").change_version()<cr>', opts)
