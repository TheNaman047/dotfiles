vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/pwntester/octo.nvim",
})

require("octo").setup({
  picker = "snacks",
  enable_builtin = true,
})

-- stylua: ignore start
local keymaps = {
  { "<leader>gpr", "<cmd>Octo pr list<cr>",      desc = "List PRs" },
  { "<leader>gps", "<cmd>Octo pr search<cr>",    desc = "Search PRs" },
  -- bare `Octo review` = start_or_resume; `review start` hard-fails if a pending review exists
  { "<leader>gpR", "<cmd>Octo review<cr>",       desc = "Start/resume PR review" },
  { "<leader>gir", "<cmd>Octo issue list<cr>",   desc = "List issues" },
}
-- stylua: ignore end
for _, m in ipairs(keymaps) do
  vim.keymap.set("n", m[1], m[2], { desc = m.desc })
end
