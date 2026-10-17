vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-lua/plenary.nvim",
})

-- nvim-treesitter `main` branch (needs `tree-sitter` CLI); install() skips already-installed parsers
require("nvim-treesitter").install({ "lua", "vim", "vimdoc", "markdown", "markdown_inline", "javascript", "typescript", "json", "python", "toml", "rust", "sql", "tsx", "yaml", "dockerfile", "terraform", "hcl", })

vim.api.nvim_create_autocmd("FileType", {
  callback = function() pcall(vim.treesitter.start) end, -- pcall: filetypes without a parser
})
