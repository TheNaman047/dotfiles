local dadbod_ui = {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod" },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } },
	},
	keys = { -- Mapping to toggle DBUI
		{ "<leader>d", "<cmd>DBUIToggle<CR>", desc = "Toggle DBUI" },
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	init = function()
		vim.g.db_ui_show_help = 0
		vim.g.db_ui_win_position = "right"
		vim.g.db_ui_use_nerd_fonts = 1

		-- This sets the location of the `connections.json` file, which includes the
		-- DB conection strings (includes passwords in plaintext, so do not track
		-- this file. Storing it in iCloud but this is only for my homelab)
		-- The default location for this is `~/.local/share/db_ui`
		vim.g.db_ui_save_location = "~/Applications/dadbod-ui/"
		-- vim.g.db_ui_save_location = "~/.ssh/dbui"
		-- vim.g.db_ui_tmp_query_location = "~/github/dotfiles-latest/neovim/neobean/dadbod/queries"

	end,
}

return { dadbod_ui }
