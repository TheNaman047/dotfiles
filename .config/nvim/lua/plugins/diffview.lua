vim.pack.add({
  "https://github.com/sindrets/diffview.nvim",
})

require("diffview").setup({
  enhanced_diff_hl = true,
  file_panel = {
    listing_style = "tree",
  },
})

-- stylua: ignore start
local keymaps = {
  { "<leader>gd", "<cmd>DiffviewOpen<cr>",          desc = "Diff working tree" },
  { "<leader>gD", "<cmd>DiffviewOpen HEAD~1<cr>",   desc = "Diff last commit" },
  { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
  { "<leader>gx", "<cmd>DiffviewClose<cr>",         desc = "Close diffview" },
}
-- stylua: ignore end
for _, m in ipairs(keymaps) do
  vim.keymap.set("n", m[1], m[2], { desc = m.desc })
end
