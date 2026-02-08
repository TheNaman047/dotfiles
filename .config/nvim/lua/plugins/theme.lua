vim.pack.add({
  "https://github.com/vague2k/vague.nvim",
  "https://github.com/rose-pine/neovim",
})

-- Set colorscheme
-- vim.cmd("colorscheme vague")
vim.cmd("colorscheme rose-pine")
vim.cmd(":hi statusline guibg=NONE")

-- require "vague".setup({ transparent = true })
require "rose-pine".setup({
  styles = {
    transparency = true,
  },
  dim_inactive_windows = true
})
