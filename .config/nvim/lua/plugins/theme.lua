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
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        -- add any options here
        cmdline = {
          enabled = false,
        },
        messages = {
          enabled = false,
        },
        popupmenu = {
          enabled = true,
        },
        notify = {
          enabled = false,
        },
        lsp = {
          message = {
            enabled = false,
          },
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
          },
        },
      })
    end,
  },
}
