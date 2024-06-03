-- Set common opts
local opts = { noremap = true, silent = true }
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({})
      vim.api.nvim_set_keymap("n", "<leader>t", ":ToggleTerm<cr>", opts)
      vim.api.nvim_set_keymap("n", "<leader>o", ":ToggleTerm new<cr>", opts)
      vim.api.nvim_set_keymap("n", "<leader>c", ":ToggleTerm close<cr>", opts)
    end,
  },
}
