return {
  "nvim-treesitter/nvim-treesitter",
  event = "BufReadPost",
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      ensure_installed = {
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "javascript",
        "typescript",
        "bash",
        "json",
        "python",
        "toml",
        "rust",
        "sql",
        "tsx",
        "yaml",
        "css",
        "html",
        "dockerfile",
        "terraform",
        "hcl",
        "markdown",
        "markdown_inline"
      },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
