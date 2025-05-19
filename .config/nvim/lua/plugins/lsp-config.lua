local Utils = require("../utils/functions")

local lsp_servers = {
  html = {},
  cssls = {},
  lua_ls = {},
  jsonls = {},
  docker_compose_language_service = {},
  dockerls = {},
  pylsp = {
    settings = {
      pylsp = {
        plugins = {
          pyflakes = { enabled = false },
          pycodestyle = { enabled = false },
          autopep8 = { enabled = false },
          yapf = { enabled = false },
          mccabe = { enabled = false },
          pylsp_mypy = { enabled = false },
          pylsp_black = { enabled = false },
          pylsp_isort = { enabled = false },
        },
      },
    },
  },
  ruff = {},
  tailwindcss = {},
  terraformls = {},
  yamlls = {},
  volar = { "vue" },
  ts_ls = {
    init_options = {
      plugins = {
        {
          name = '@vue/typescript-plugin',
          location = vim.fn.expand("$MASON/packages/vue-language-server/node_modules/@vue/language-server"),
          languages = { 'vue' },
        },
      },
    },
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'svelte' },
  },
}

-- Update to use mason-tool for auto-installation 
local formatters = {
  prettier = {},
  prettierd = {},
  shfmt = {},
}

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
  buf_set_keymap("n", "gr", "<cmd>Telescope lsp_references<CR>", Utils.opts)
  buf_set_keymap("n", "<leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", Utils.opts)
  buf_set_keymap("n", "<leader>ca", "<Cmd>lua vim.lsp.buf.code_action()<CR>", Utils.opts)
  buf_set_keymap("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<CR>", Utils.opts)
  buf_set_keymap("n", "<leader>ws", "<cmd>Telescope lsp_workspace_symbols<CR>", Utils.opts)
  buf_set_keymap("n", "]d", "<Cmd>lua vim.diagnostic.goto_next()<CR>", Utils.opts)
  buf_set_keymap("n", "[d", "<Cmd>lua vim.diagnostic.goto_prev()<CR>", Utils.opts)
  buf_set_keymap("n", "gl", "<cmd>Telescope diagnostics bufnr=0<CR>", Utils.opts)
end

local mason = {
  "mason-org/mason.nvim",
  cmd = {
    "Mason",
    "MasonInstall",
    "MasonUninstall",
    "MasonUninstallAll",
    "MasonLog",
  },
}

local mason_lsp_config = {
  "mason-org/mason-lspconfig.nvim",
  event = "BufReadPost",
  dependencies = {
    "mason-org/mason.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function(_, opts)
    local mason = require('mason')
    local mason_lsp_config = require('mason-lspconfig')
    mason.setup({})
    mason_lsp_config.setup({
      ensure_installed = vim.tbl_keys(lsp_servers),
      automatic_installation = true,
    })

    for server, config in pairs(lsp_servers) do
      vim.lsp.config(server, config)
      vim.lsp.enable(server)
    end
  end
}

local none_ls_config = {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls_config = require("null-ls")
    null_ls_config.setup({
      sources = {
        require("none-ls.formatting.ruff").with({ extra_args = { "--extend-select", "I" } }),
        require("none-ls.formatting.ruff_format"),
        null_ls_config.builtins.code_actions.gitsigns,
        null_ls_config.builtins.formatting.prettier.with({
          filetypes = {
            "json",
            "yaml",
            "markdown",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue"
          }
        }),
        null_ls_config.builtins.formatting.shfmt.with({ args = { "-i", "4" } }),
        null_ls_config.builtins.formatting.terraform_fmt,
        null_ls_config.builtins.diagnostics.terraform_validate
      },
    })
    vim.keymap.set("n", "fe", "<Cmd>lua vim.diagnostic.open_float()<CR>", Utils.opts)
    vim.keymap.set("n", "fd", "<Cmd>lua vim.lsp.buf.format()<CR>", Utils.opts)
  end,
}

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if client then
      on_attach(client, bufnr)
    end

    if client:supports_method "textDocument/inlayHint" then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
})

return { mason, mason_lsp_config, none_ls_config }
