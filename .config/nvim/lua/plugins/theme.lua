-- Reads the key set-theme.sh wrote and loads only that theme's plugin.
-- Intentionally read once at startup only, so running instances are never force-reloaded.

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
      require("catppuccin").setup({ flavour = "mocha" })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  ["tokyonight-storm"] = {
    repo = "https://github.com/folke/tokyonight.nvim",
    apply = function()
      require("tokyonight").setup({ style = "storm" })
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  ["rose-pine-moon"] = {
    repo = "https://github.com/rose-pine/neovim",
    apply = function()
      require("rose-pine").setup({ variant = "moon" })
      vim.cmd.colorscheme("rose-pine")
    end,
  },
  ["dracula"] = {
    repo = "https://github.com/Mofiqul/dracula.nvim",
    apply = function()
      vim.cmd.colorscheme("dracula")
    end,
  },
  ["gruvbox-dark"] = {
    repo = "https://github.com/ellisonleao/gruvbox.nvim",
    apply = function()
      require("gruvbox").setup({ contrast = "hard" })
      vim.cmd.colorscheme("gruvbox")
    end,
  },
  ["nord"] = {
    repo = "https://github.com/gbprod/nord.nvim",
    apply = function()
      vim.cmd.colorscheme("nord")
    end,
  },
  ["solarized-dark"] = {
    repo = "https://github.com/maxmx03/solarized.nvim",
    apply = function()
      require("solarized").setup({})
      vim.cmd.colorscheme("solarized")
    end,
  },
  ["onedark"] = {
    repo = "https://github.com/navarasu/onedark.nvim",
    apply = function()
      require("onedark").setup({ style = "dark" })
      require("onedark").load()
    end,
  },
  ["everforest-dark-hard"] = {
    repo = "https://github.com/sainnhe/everforest",
    apply = function()
      vim.g.everforest_background = "hard"
      vim.cmd.colorscheme("everforest")
    end,
  },
  ["gruvbox-material-dark"] = {
    repo = "https://github.com/sainnhe/gruvbox-material",
    apply = function()
      vim.g.gruvbox_material_background = "hard"
      vim.cmd.colorscheme("gruvbox-material")
    end,
  },
  ["nightfox"] = {
    repo = "https://github.com/EdenEast/nightfox.nvim",
    apply = function()
      vim.cmd.colorscheme("nightfox")
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
