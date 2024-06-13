-- Language Servers
local lsp_servers = { "lua_ls", "rust_analyzer", "tsserver" }
-- Set common opts
local opts = { noremap = true, silent = true }

-- Define a function to set up the keymaps
local function on_attach(client, bufnr)
	-- Helper function to set keymaps
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end

	-- Define keymaps using <Cmd>lua
	buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
	buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	buf_set_keymap("n", "gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
	buf_set_keymap("n", "<C-k>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	vim.keymap.set("n", "gr", function()
		require("telescope.builtin").lsp_references()
	end, opts)
	buf_set_keymap("n", "<leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
	buf_set_keymap("n", "<leader>ca", "<Cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	buf_set_keymap("n", "]d", "<Cmd>lua vim.diagnostic.goto_next()<CR>", opts)
	buf_set_keymap("n", "[d", "<Cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
	buf_set_keymap("n", "gl", "<Cmd>lua vim.diagnostic.open_float()<CR>", opts)
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
				ensure_installed = lsp_servers,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local config = require("lspconfig")
			-- Adding capabilities from 'cmp_nvim_lsp'
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			for _, lsp in ipairs(lsp_servers) do
				config[lsp].setup({
					on_attach = on_attach,
					capabilities = capabilities,
				})
			end
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		config = function()
			local null_ls = require("null-ls")

			null_ls.setup({
				sources = {
					-- Formatting
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.biome.with({
						filetypes = {
							"javascript",
							"javascriptreact",
							"json",
							"jsonc",
							"typescript",
							"typescriptreact",
						},
						args = {
							"check",
							"--apply-unsafe",
							"--formatter-enabled=true",
							"--organize-imports-enabled=true",
							"--skip-errors",
							"--stdin-file-path=$FILENAME",
						},
					}),
					null_ls.builtins.formatting.black,

					-- Diagnostics
					null_ls.builtins.diagnostics.eslint_lsp,
					null_ls.builtins.diagnostics.pylint,
				},
			})
			vim.keymap.set("n", "fd", "<Cmd>lua vim.lsp.buf.format()<CR>", opts)
		end,
	},
}
