vim.pack.add({
  "https://github.com/OXY2DEV/markview.nvim",
})

-- Split-only preview. preview.enable = false disables all in-buffer
-- rendering (no preview on open, no cursor-line flicker); the split preview
-- renders independently in its own scroll-synced window via splitToggle.
require("markview").setup({
  preview = { enable = false },
})

vim.keymap.set("n", "<leader>mv", "<cmd>Markview splitToggle<CR>", { desc = "Toggle markdown preview split" })
