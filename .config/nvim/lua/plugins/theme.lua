vim.pack.add({
  "https://github.com/vague2k/vague.nvim",
  "https://github.com/rose-pine/neovim",
  "https://github.com/rebelot/kanagawa.nvim",
})

-- require "rose-pine".setup({
--   styles = {
--     transparency = true,
--   },
--   dim_inactive_windows = true
-- })

require "kanagawa".setup({
    compile = false,             -- enable compiling the colorscheme
    undercurl = true,            -- enable undercurls
    commentStyle = { italic = true },
    functionStyle = {},
    keywordStyle = { italic = true},
    statementStyle = { bold = true },
    typeStyle = {},
    transparent = false,         -- do not set background color
    dimInactive = true,         -- dim inactive window `:h hl-NormalNC`
    terminalColors = true,       -- define vim.g.terminal_color_{0,17}
    theme = "wave",              -- Load "wave" theme
    background = {               -- map the value of 'background' option to a theme
        dark = "wave",           -- try "dragon" !
        light = "lotus"
    },
})

-- Set colorscheme
-- vim.cmd("colorscheme vague")
-- vim.cmd("colorscheme rose-pine")
vim.cmd("colorscheme kanagawa")
vim.cmd(":hi statusline guibg=NONE")

-- require "vague".setup({ transparent = true })
