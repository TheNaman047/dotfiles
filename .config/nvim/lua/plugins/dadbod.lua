local augroup = require("utils").augroup

vim.pack.add({
  "https://github.com/kristijanhusak/vim-dadbod-ui",
  "https://github.com/tpope/vim-dadbod",
  "https://github.com/kristijanhusak/vim-dadbod-completion",
})

vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_show_help = 0
vim.g.db_ui_win_position = "right"
vim.g.db_ui_winwidth = 35
vim.g.db_ui_auto_execute_table_helpers = 1

-- Store connections/queries outside the dotfiles repo (contains plaintext passwords)
vim.g.db_ui_save_location = vim.fn.expand("~/.local/share/db_ui")

-- Load named connections from a private, git-ignored file
local ok, dbs = pcall(require, "private.db_connections")
if ok then
  vim.g.dbs = dbs
end

vim.keymap.set("n", "<leader>d", ":DBUIToggle<CR>", { noremap = true, silent = true, desc = "Toggle DB UI" })

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("dadbod_result"),
  pattern = { "dbout", "json" },
  callback = function(ev)
    local name = vim.api.nvim_buf_get_name(ev.buf)
    -- only apply to dadbod result buffers
    if vim.bo[ev.buf].filetype == "json" and not name:match("dadbod") then
      return
    end
    vim.opt_local.foldenable = true
    vim.opt_local.foldmethod = "indent"
    vim.opt_local.foldlevel = 1
    vim.opt_local.wrap = false
  end,
})
