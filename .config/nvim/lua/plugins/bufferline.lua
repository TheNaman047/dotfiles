return {
	{
		"moll/vim-bbye",
		event = "VeryLazy",
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		keys = {
			{
				"gjn",
				":lua require'bufferline'.cycle(1)<CR>",
				silent = true,
				noremap = true,
				desc = "Bufferline cycle through buffers right",
			},
			{
				"gjp",
				":lua require'bufferline'.cycle(-1)<CR>",
				silent = true,
				noremap = true,
				desc = "Bufferline cycle through buffers left",
			},
			{
				"gjd",
				":Bdelete<CR>",
				silent = true,
				noremap = true,
				desc = "Bufferline close tab",
			},
			{
				"gjx",
				":bd<CR>",
				silent = true,
				noremap = true,
				desc = "Bufferline close buffer",
			},
			{
				"gjs",
				":w<CR>",
				silent = true,
				noremap = true,
				desc = "Bufferline save buffer",
			},
		},
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
		end,
	},
}
