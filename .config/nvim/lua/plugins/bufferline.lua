return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons"},
  config = function()
    require("bufferline").setup({
      options = {
        offsets = {
          {
            filetype = "neo-tree",
            text = "Explorer",
            text_align = "left",
            separator = true,
          },
        },
        diagnostics = "nvim_lsp",
        color_icons = true,
        separator_style = "slope",
      },
    })
    local opts = { noremap = true, silent = true }
    -- Bufferline cycle through buffers
    vim.api.nvim_set_keymap("n", "gbp", ":lua require'bufferline'.cycle(1)<CR>", opts)
    vim.api.nvim_set_keymap("n", "gbn", ":lua require'bufferline'.cycle(-1)<CR>", opts)
    -- Bufferline close buffer
    vim.api.nvim_set_keymap("n", "gbd", ":bd<CR>", opts)
    -- Bufferline save buffer
    vim.api.nvim_set_keymap("n", "gbs", ":w<CR>", opts)
  end,
}