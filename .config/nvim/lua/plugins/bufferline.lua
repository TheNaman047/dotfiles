return {
	{
		"moll/vim-bbye",
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
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
					hover = {
						enabled = true,
						delay = 200,
						reveal = { "close" },
					},
				},
			})
			local opts = { noremap = true, silent = true }
			-- Bufferline cycle through buffers
			vim.api.nvim_set_keymap("n", "gjn", ":lua require'bufferline'.cycle(1)<CR>", opts)
			vim.api.nvim_set_keymap("n", "gjp", ":lua require'bufferline'.cycle(-1)<CR>", opts)
			-- Bufferline close tab
			vim.api.nvim_set_keymap("n", "gjd", ":Bdelete<CR>", opts)
			-- Bufferline close buffer
			vim.api.nvim_set_keymap("n", "gjx", ":bd<CR>", opts)
			-- Bufferline save buffer
			vim.api.nvim_set_keymap("n", "gjs", ":w<CR>", opts)
		end,
	},
}
