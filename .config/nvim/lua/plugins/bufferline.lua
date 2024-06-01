return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
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
			},
		})
		local opts = { noremap = true, silent = true }
		-- Bufferline cycle through buffers
		vim.api.nvim_set_keymap("n", "bp", ":lua require'bufferline'.cycle(1)<CR>", opts)
		vim.api.nvim_set_keymap("n", "bn", ":lua require'bufferline'.cycle(-1)<CR>", opts)
	end,
}
