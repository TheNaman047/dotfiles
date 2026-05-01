-- LSP
local augroup = require("utils").augroup

local default_keymaps = {
  { keys = "<leader>ca", func = vim.lsp.buf.code_action, desc = "Code Actions" },
  { keys = "<leader>cr", func = vim.lsp.buf.rename,      desc = "Code Rename" },
  { keys = "<leader>k",  func = vim.lsp.buf.hover,       desc = "Hover Documentation", has = "hoverProvider" },
  { keys = "K",          func = vim.lsp.buf.hover,       desc = "Hover (alt)",         has = "hoverProvider" },
  { keys = "gd",         func = vim.lsp.buf.definition,  desc = "Goto Definition",     has = "definitionProvider" },
  { keys = "<leader>fd", func = function()
    local params = vim.lsp.util.make_formatting_params()
    vim.lsp.buf_request(0, 'textDocument/rangeFormatting', params, function(err, result, ctx)
      if not err and result then
        vim.lsp.util.apply_text_edits(result, ctx.bufnr, 'utf-16')
      end
    end)
  end, desc = "Format Code" },
}

-- I use blink.cmp for completion, but you can use native completion too
local completion = vim.g.completion_mode or "blink" -- or 'native' for built-in completion
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("lsp_attach"),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local buf = args.buf
    if client then
      -- Built-in completion
      if completion == "native" and client:supports_method("textDocument/completion") then
        vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
      end

      -- Inlay hints
      if client:supports_method("textDocument/inlayHints") then
        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
      end

      if client:supports_method("textDocument/documentColor") then
        vim.lsp.document_color.enable(true, {
          bufnr = args.buf,
        })
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

-- Enable LSP servers for Neovim 0.11+
vim.lsp.enable({
  "ts_go_ls",
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
