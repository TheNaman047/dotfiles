return {
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.6",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			-- Load fzf native
			local telescope = require("telescope")
			telescope.setup({
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "ignore_case",
					},
				},
			})
			telescope.load_extension("fzf")

			-- Setup keymaps
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", function()
				return builtin.find_files({ find_command = { "rg", "--files", "--hidden", "-g", "!.git" } })
			end, {})
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
			vim.keymap.set(
				"n",
				"<leader>fc",
				'<cmd>lua require("telescope.builtin").live_grep({ glob_pattern = "!{spec,test}"})<CR>',
				{ desc = "Live Grep Code" }
			)
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help Tags" })
			vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find Symbols" })
			vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Find Old Files" })
			vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find Word under Cursor" })
			vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Search Git Commits" })
			vim.keymap.set("n", "<leader>gb", builtin.git_bcommits, { desc = "Search Git Commits for Buffer" })
			vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find Keymaps" })
			vim.keymap.set("n", "<leader>/", function()
				-- You can pass additional configuration to telescope to change theme, layout, etc.
				require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = true,
					layout_config = { width = 0.6 },
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })
		end,
	},
}
