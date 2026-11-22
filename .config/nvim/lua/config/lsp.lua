-- LSP
local augroup = require("utils").augroup

local default_keymaps = {
  { keys = "<leader>ca", func = vim.lsp.buf.code_action, desc = "Code Actions" },
  { keys = "<leader>cr", func = vim.lsp.buf.rename,      desc = "Code Rename" },
  { keys = "<leader>k",  func = vim.lsp.buf.hover,       desc = "Hover Documentation", has = "hoverProvider" },
  { keys = "K",          func = vim.lsp.buf.hover,       desc = "Hover (alt)",         has = "hoverProvider" },
  { keys = "gd",         func = vim.lsp.buf.definition,  desc = "Goto Definition",     has = "definitionProvider" },
}

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("lsp_attach"),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local buf = args.buf
    if client then
      if client:supports_method("textDocument/inlayHints") then
        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
      end

      if client:supports_method("textDocument/documentColor") then
        vim.lsp.document_color.enable(true, { bufnr = args.buf })
      end

      if client.name == 'ruff' then
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
      end

      for _, km in ipairs(default_keymaps) do
        -- Only bind if there's no `has` requirement, or the server supports it
        if not km.has or client.server_capabilities[km.has] then
          vim.keymap.set(
            km.mode or "n",
            km.keys,
            km.func,
            { buffer = buf, desc = "LSP: " .. km.desc, nowait = km.nowait }
          )
        end
      end
    end
  end,
})

-- Nvim never stops a server on its own, so closed projects kept theirs running
-- for the life of the instance. The delay rides out `:e` re-attaches.
vim.api.nvim_create_autocmd("LspDetach", {
  group = augroup("lsp_stop_unused"),
  callback = function(args)
    local id = args.data.client_id
    vim.defer_fn(function()
      local client = vim.lsp.get_client_by_id(id)
      if client and vim.tbl_isempty(client.attached_buffers) then
        client:stop()
      end
    end, 10000)
  end,
})

-- Enable LSP servers for Neovim 0.11+
vim.lsp.enable({
  "tsc",
  "vtsls",
  "lua_ls",
  "vue_ls",
  "basedpyright",
  "ruff",
  "yamlls",
  "jsonls",
  "rust_analyzer",
  "html",
  "tailwindcss",
})

-- Load Lsp on-demand, e.g: eslint is disable by default
-- e.g: We could enable eslint by set vim.g.lsp_on_demands = {"eslint"}
if vim.g.lsp_on_demands then
  vim.lsp.enable(vim.g.lsp_on_demands)
end
