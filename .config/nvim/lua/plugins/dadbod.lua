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

-- Open the drawer with one named connection expanded (connected), e.g. from
-- tmux: nvim -c 'DBUIConnect spotlight1-pgcat-dev'. dadbod-ui has no API for
-- this, so it drives the drawer line the way pressing <CR> on it would.
vim.api.nvim_create_user_command("DBUIConnect", function(opts)
  vim.cmd("DBUI")
  for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local trimmed = vim.trim(line)
    if trimmed == opts.args or vim.endswith(trimmed, " " .. opts.args) then
      vim.api.nvim_win_set_cursor(0, { i, 0 })
      vim.cmd([[execute "normal \<Plug>(DBUI_SelectLine)"]])
      return
    end
  end
  vim.notify("DBUIConnect: no connection named " .. opts.args, vim.log.levels.WARN)
end, {
  nargs = 1,
  complete = function()
    return vim.tbl_map(function(db) return db.name end, vim.g.dbs or {})
  end,
})

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
