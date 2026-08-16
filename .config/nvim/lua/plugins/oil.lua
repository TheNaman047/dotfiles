vim.pack.add({
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/refractalize/oil-git-status.nvim"
})

require "oil".setup({
  win_options = {
    signcolumn = "yes:2",
  },
  delete_to_trash = true,
  view_options = {
    show_hidden = true,
  },
  keymaps = {
    ["<C-t>"] = { "actions.select", opts = { tab = true } },
    ["<C-r>"] = { "actions.preview", opts = { split = "botright" } },
    ["<C-p>"] = false,
    ["g."] = { "actions.toggle_hidden", mode = "n" },
    -- Unbind oil's defaults (<C-h> select_split, <C-l> refresh) so the global
    -- <C-hjkl> maps from after/plugin/herdr_nav.lua apply in oil buffers too.
    ["<C-h>"] = false,
    ["<C-j>"] = false,
    ["<C-k>"] = false,
    ["<C-l>"] = false,
  },
})

local opts = { noremap = true, silent = true }

-- Oil keymaps
vim.keymap.set("n", "-", "<CMD>Oil<CR>", opts)
vim.keymap.set("n", "<leader>-", "<CMD>Oil --float<CR>", opts)
