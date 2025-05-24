return {
  -- {
  -- 	"catppuccin/nvim",
  -- 	name = "catppuccin",
  -- 	lazy = false,
  -- 	priority = 1000,
  -- 	config = function()
  -- 		vim.cmd([[colorscheme catppuccin]])
  -- 	end,
  -- },
  -- {
  --   "rose-pine/neovim",
  --   name = "rose-pine",
  --   config = function()
  --     require("rose-pine").setup({
  --       dim_inactive_windows = true,
  --     })
  --     vim.cmd([[colorscheme rose-pine]])
  --   end,
  -- },
  -- {
  -- 	"jdsimcoe/hyper.vim",
  -- 	name = "hyper",
  -- 	config = function()
  -- 		vim.cmd([[colorscheme hyper]])
  -- 	end,
  -- },
  {
    "folke/tokyonight.nvim",
    opts = {},
    config = function()
      local tokyoNight = require("tokyonight")
      tokyoNight.setup({
        style = "night",
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
      })
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
  -- {
  -- 	"ray-x/aurora",
  -- 	init = function()
  -- 		vim.g.aurora_italic = 1
  -- 		vim.g.aurora_transparent = 1
  -- 		-- vim.g.aurora_bold = 1
  -- 	end,
  -- 	config = function()
  --     vim.cmd([[colorscheme aurora]])
  -- 		-- override defaults
  -- 		vim.api.nvim_set_hl(0, "@number", { fg = "#e933e3" })
  -- 	end,
  -- },
}
