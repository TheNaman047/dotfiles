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
  --   "ray-x/aurora",
  --   init = function()
  --     vim.g.aurora_italic = 1
  --     vim.g.aurora_transparent = 1
  --     -- vim.g.aurora_darker = 1
  --     -- vim.g.aurora_bold = 1
  --   end,
  --   config = function()
  --     vim.cmd([[colorscheme aurora]])
  --     -- Override problematic highlight groups
  --     local overrides = {
  --       -- Common problematic groups
  --       ["@number"] = { fg = "#e933e3" },
  --       -- ["@string"] = { fg = "#98c379" },
  --       -- ["@comment"] = { fg = "#7c7c7c", italic = true },
  --       -- ["Normal"] = { fg = "#abb2bf" },
  --       -- ["Identifier"] = { fg = "#e06c75" },
  --       -- ["Function"] = { fg = "#61afef" },
  --       -- ["Keyword"] = { fg = "#c678dd" },
  --       -- ["Type"] = { fg = "#e5c07b" },
  --       -- ["Constant"] = { fg = "#d19a66" },
  --       -- ["Special"] = { fg = "#56b6c2" },
  --       -- -- Add background for better contrast if needed
  --       -- ["CursorLine"] = { bg = "#2c323c" },
  --       -- ["Visual"] = { bg = "#3e4451" },
  --     }
  --
  --     for group, opts in pairs(overrides) do
  --       vim.api.nvim_set_hl(0, group, opts)
  --     end
  --   end,
  -- },
}
