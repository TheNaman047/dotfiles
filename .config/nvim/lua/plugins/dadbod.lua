vim.pack.add({
  "https://github.com/kristijanhusak/vim-dadbod-ui",
  "https://github.com/tpope/vim-dadbod",
  "https://github.com/kristijanhusak/vim-dadbod-completion",
})

-- Setup dadbod module
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

-- Keymaps
vim.keymap.set("n", "<leader>d", ":DBUIToggle<CR>", opts)
