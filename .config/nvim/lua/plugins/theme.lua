-- Reads the key set-theme.sh wrote and loads only that theme's plugin.
-- Intentionally read once at startup only, so running instances are never force-reloaded.

local function nightfox_setup()
  require("nightfox").setup({
    options = {
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = "italic",
        keywords = "italic",
      },
      inverse = {
        match_paren = false,
        visual = false,
        search = false,
      },
    },
  })
end

local THEMES = {
  ["kanagawa-wave"] = {
    repo = "https://github.com/rebelot/kanagawa.nvim",
    apply = function()
      require("kanagawa").setup({
        compile = false,
        undercurl = true,
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false,
        dimInactive = true,
        terminalColors = true,
        theme = "wave",
        background = { dark = "wave", light = "lotus" },
      })
      vim.cmd.colorscheme("kanagawa")
    end,
  },
  ["catppuccin-mocha"] = {
    repo = "https://github.com/catppuccin/nvim",
    apply = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        term_colors = true,
        default_integrations = true,
        integrations = {
          blink_cmp = true,
          gitsigns = true,
          which_key = true,
          diffview = true,
          mini = { enabled = true },
          snacks = { enabled = true },
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  ["tokyonight-storm"] = {
    repo = "https://github.com/folke/tokyonight.nvim",
    apply = function()
      require("tokyonight").setup({
        style = "storm",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  ["rose-pine-moon"] = {
    repo = "https://github.com/rose-pine/neovim",
    apply = function()
      require("rose-pine").setup({
        variant = "moon",
        dark_variant = "moon",
        styles = {
          bold = true,
          italic = true,
          transparency = false,
        },
        groups = {
          border = "muted",
          link = "iris",
          panel = "surface",
          error = "love",
          hint = "iris",
          info = "foam",
          note = "pine",
          todo = "rose",
          warn = "gold",
          git_add = "foam",
          git_change = "rose",
          git_delete = "love",
          git_dirty = "rose",
          git_ignore = "muted",
          git_merge = "iris",
          git_rename = "pine",
          git_stage = "iris",
          git_text = "rose",
          git_untracked = "subtle",
        },
      })
      vim.cmd.colorscheme("rose-pine")
    end,
  },
  ["dracula"] = {
    repo = "https://github.com/Mofiqul/dracula.nvim",
    apply = function()
      require("dracula").setup({
        italic_comment = true,
        transparent_bg = false,
        show_end_of_buffer = false,
        overrides = {},
      })
      vim.cmd.colorscheme("dracula")
    end,
  },
  ["gruvbox-dark"] = {
    repo = "https://github.com/ellisonleao/gruvbox.nvim",
    apply = function()
      require("gruvbox").setup({
        contrast = "hard",
        terminal_colors = true,
        transparent_mode = false,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        overrides = {},
      })
      vim.cmd.colorscheme("gruvbox")
    end,
  },
  ["nord"] = {
    repo = "https://github.com/gbprod/nord.nvim",
    apply = function()
      require("nord").setup({
        transparent = false,
        terminal_colors = true,
        borders = true,
        diff = { mode = "bg" },
        errors = { mode = "bg" },
        search = { theme = "vim" },
        styles = {
          comments = { italic = true },
        },
      })
      vim.cmd.colorscheme("nord")
    end,
  },
  ["solarized-dark"] = {
    repo = "https://github.com/maxmx03/solarized.nvim",
    apply = function()
      require("solarized").setup({
        variant = "winter",
        transparent = { enabled = false },
        styles = {
          comments = { italic = true },
          functions = { italic = true },
          keywords = { italic = true },
        },
        plugins = {
          treesitter = true,
          gitsigns = true,
          whichkey = true,
        },
      })
      vim.cmd.colorscheme("solarized")
    end,
  },
  ["onedark"] = {
    repo = "https://github.com/navarasu/onedark.nvim",
    apply = function()
      require("onedark").setup({
        style = "dark",
        transparent = false,
        term_colors = true,
        code_style = {
          comments = "italic",
        },
        diagnostics = {
          darker = true,
          undercurl = true,
          background = true,
        },
      })
      require("onedark").load()
    end,
  },
  ["everforest-dark-hard"] = {
    repo = "https://github.com/sainnhe/everforest",
    apply = function()
      vim.g.everforest_background = "hard"
      vim.g.everforest_better_performance = 1
      vim.g.everforest_enable_italic = 1
      vim.g.everforest_diagnostic_text_highlight = 1
      vim.g.everforest_diagnostic_virtual_text = "colored"
      vim.g.everforest_dim_inactive_windows = 1
      vim.cmd.colorscheme("everforest")
    end,
  },
  ["gruvbox-material-dark"] = {
    repo = "https://github.com/sainnhe/gruvbox-material",
    apply = function()
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_diagnostic_text_highlight = 1
      vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
      vim.g.gruvbox_material_dim_inactive_windows = 1
      vim.cmd.colorscheme("gruvbox-material")
    end,
  },
  ["nightfox"] = {
    repo = "https://github.com/EdenEast/nightfox.nvim",
    apply = function()
      nightfox_setup()
      vim.cmd.colorscheme("nightfox")
    end,
  },
  ["duskfox"] = {
    repo = "https://github.com/EdenEast/nightfox.nvim",
    apply = function()
      nightfox_setup()
      vim.cmd.colorscheme("duskfox")
    end,
  },
  ["nordfox"] = {
    repo = "https://github.com/EdenEast/nightfox.nvim",
    apply = function()
      nightfox_setup()
      vim.cmd.colorscheme("nordfox")
    end,
  },
  ["carbonfox"] = {
    repo = "https://github.com/EdenEast/nightfox.nvim",
    apply = function()
      nightfox_setup()
      vim.cmd.colorscheme("carbonfox")
    end,
  },
  ["terafox"] = {
    repo = "https://github.com/EdenEast/nightfox.nvim",
    apply = function()
      nightfox_setup()
      vim.cmd.colorscheme("terafox")
    end,
  },
}

local DEFAULT_KEY = "kanagawa-wave"

local function read_current_theme()
  local f = io.open(vim.fn.expand("~/.config/theme/current"), "r")
  if not f then
    return DEFAULT_KEY
  end
  local key = f:read("l")
  f:close()
  key = key and vim.trim(key) or ""
  return (key ~= "" and THEMES[key]) and key or DEFAULT_KEY
end

local theme = THEMES[read_current_theme()]

vim.pack.add({ theme.repo })
theme.apply()
