vim.pack.add({
  "https://github.com/stevearc/conform.nvim",
})

-- Projects pin their own prettier; only run it where a config exists, else fall back to LSP
local prettier = { "prettier" }

-- dadbod-ui stores the connection URL in b:db; map its scheme to a sql-formatter dialect
local sql_dialects = {
  postgres = "postgresql",
  postgresql = "postgresql",
  mysql = "mysql",
  mariadb = "mariadb",
  sqlite = "sqlite",
  sqlserver = "transactsql",
}

require("conform").setup({
  formatters_by_ft = {
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    vue = prettier,
    css = prettier,
    scss = prettier,
    less = prettier,
    html = prettier,
    json = prettier,
    jsonc = prettier,
    yaml = prettier,
    markdown = prettier,
    graphql = prettier,
    sql = { "sql_formatter" },
    mysql = { "sql_formatter" },
    plsql = { "sql_formatter" },
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
  formatters = {
    prettier = {
      require_cwd = true,
    },
    sql_formatter = {
      cwd = require("conform.util").root_file({ ".sql-formatter.json" }),
      prepend_args = function(_, ctx)
        local url = vim.b[ctx.buf].db
        local scheme = type(url) == "string" and url:match("^(%w+):") or nil
        local lang = scheme and sql_dialects[scheme:lower()]
        if not lang then
          if vim.fs.root(ctx.buf, ".sql-formatter.json") then
            return {}
          end
          -- generic "sql" dialect chokes on pg syntax like ::casts
          lang = "postgresql"
        end
        return { "-c", vim.json.encode({ language = lang, keywordCase = "upper", tabWidth = 2 }) }
      end,
    },
  },
})

vim.keymap.set({ "n", "v" }, "<leader>fd", function()
  require("conform").format({ async = true })
end, { desc = "Format Code" })
