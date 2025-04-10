local Utils = require("../utils/functions")
-- Language Servers
local lsp_servers = {
  "html",
  "cssls",
  "lua_ls",
  "rust_analyzer",
  "jsonls",
  "docker_compose_language_service",
  "dockerls",
  "basedpyright",
  "tailwindcss",
  "yamlls",
  volar = { "vue" },
}
local custom_lsp_servers = {
  "denols",
  "ts_ls",
}
-- Concatenate the tables
local all_lsp_servers = {}
vim.list_extend(all_lsp_servers, lsp_servers)
vim.list_extend(all_lsp_servers, custom_lsp_servers)

-- Set common opts
local opts = { noremap = true, silent = true }

-- Define a function to set up the keymaps
local function on_attach(client, bufnr)
  -- Helper function to set keymaps
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  -- Define keymaps using <Cmd>lua
  buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", Utils.opts)
  buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", Utils.opts)
  buf_set_keymap("n", "gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", Utils.opts)
  buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", Utils.opts)
  buf_set_keymap("n", "<C-s>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", Utils.opts)
  vim.keymap.set("n", "gr", function()
    require("telescope.builtin").lsp_references()
  end, Utils.opts)
  buf_set_keymap("n", "<leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", Utils.opts)
  buf_set_keymap("n", "<leader>ca", "<Cmd>lua vim.lsp.buf.code_action()<CR>", Utils.opts)
  buf_set_keymap("n", "]d", "<Cmd>lua vim.diagnostic.goto_next()<CR>", Utils.opts)
  buf_set_keymap("n", "[d", "<Cmd>lua vim.diagnostic.goto_prev()<CR>", Utils.opts)
  buf_set_keymap("n", "gl", "<Cmd>lua vim.diagnostic.open_float()<CR>", Utils.opts)
end

return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = all_lsp_servers,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "saghen/blink.cmp",
    },
    config = function()
      local config = require("lspconfig")
      -- Adding capabilities from 'cmp_nvim_lsp'
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      for _, lsp in ipairs(lsp_servers) do
        config[lsp].setup({
          on_attach = on_attach,
          capabilities = capabilities,
          opts = lsp_servers[lsp] or {},
        })
      end

      -- Setup for deno
      config.denols.setup({
        root_dir = config.util.root_pattern("deno.json", "deno.jsonc"),
        capabilities = capabilities,
        on_attach = on_attach,
      })
      -- Setup for basedpyright
      config.basedpyright.setup({
        before_init = function(_, c)
          if not c.settings then
            c.settings = {}
          end
          if not c.settings.python then
            c.settings.python = {}
          end
          c.settings.python.pythonPath = vim.fn.exepath("python")
        end,
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "basic",
              autoImportCompletions = true,
              diagnosticSeverityOverrides = {
                reportUnusedImport = "information",
                reportUnusedFunction = "information",
                reportUnusedVariable = "information",
                reportGeneralTypeIssues = "none",
                reportOptionalMemberAccess = "none",
                reportOptionalSubscript = "none",
                reportPrivateImportUsage = "none",
              },
            },
          },
        },
        capabilities = capabilities,
        on_attach = on_attach,
      })
      -- Setup for ts_ls and vue
      local mason_registry = require("mason-registry")
      local vue_language_server = mason_registry.get_package("vue-language-server"):get_install_path()
          .. "/node_modules/@vue/language-server"

      config.ts_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = vue_language_server,
              languages = { "vue" },
            },
          },
        },
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
      })
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local config = require("null-ls")
      config.setup({
        sources = {
          config.builtins.formatting.black,
          config.builtins.formatting.isort
        }
      })
      vim.keymap.set("n", "fe", "<Cmd>lua vim.diagnostic.open_float()<CR>", Utils.opts)
    end,
  },
}
