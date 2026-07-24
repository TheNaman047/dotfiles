vim.pack.add({
  "https://github.com/OXY2DEV/markview.nvim",
})

-- Disable in-buffer rendering (flickers on cursor move); use splitToggle instead.
require("markview").setup({
  preview = { enable = false },
})

vim.keymap.set("n", "<leader>mv", "<cmd>Markview splitToggle<CR>", { desc = "Toggle markdown preview split" })
