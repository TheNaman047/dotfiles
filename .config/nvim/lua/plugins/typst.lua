vim.pack.add({
  { src = "https://github.com/chomosuke/typst-preview.nvim", version = vim.version.range("1.*") },
})

-- setup() is what fetches/refreshes the tinymist + websocat binaries.
require("typst-preview").setup({})

vim.keymap.set("n", "<leader>mt", "<cmd>TypstPreviewToggle<CR>", { desc = "Toggle typst preview" })
