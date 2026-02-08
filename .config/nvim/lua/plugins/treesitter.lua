vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-lua/plenary.nvim",
})

require 'nvim-treesitter.configs'.setup({
  ensure_installed = { "lua", "vim", "vimdoc", "markdown", "markdown_inline", "javascript", "typescript", "json", "python", "toml", "rust", "sql", "tsx", "yaml", "dockerfile", "terraform", "hcl", },
  highlight = { enable = true }
})
