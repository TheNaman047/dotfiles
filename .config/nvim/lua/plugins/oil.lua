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
  },
})

-- Oil keymaps
vim.keymap.set("n", "-", "<CMD>Oil<CR>", opts)
vim.keymap.set("n", "<leader>-", "<CMD>Oil --float<CR>", opts)
