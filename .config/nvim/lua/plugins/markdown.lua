vim.pack.add({
  "https://github.com/OXY2DEV/markview.nvim",
})

-- Split-only preview. preview.modes = {} means the source buffer is never
-- rendered in-buffer in any mode (no cursor-line render/un-render flicker);
-- the split preview renders independently in its own scroll-synced window.
require("markview").setup({
  preview = { modes = {} },
})

vim.keymap.set("n", "<leader>mv", "<cmd>Markview splitToggle<CR>", { desc = "Toggle markdown preview split" })
