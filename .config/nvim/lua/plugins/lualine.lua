vim.pack.add({
  "https://github.com/nvim-lualine/lualine.nvim",
})

require("lualine").setup({
  options = {
    theme = "auto",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    globalstatus = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      {
        "filename",
        path = 1,
        symbols = { modified = " ", readonly = " ", unnamed = "[No Name]" },
      },
    },
    lualine_c = {
      {
        "branch",
        icon = { " ", align = "left" },
      },
      {
        "diff",
        symbols = { added = "+", modified = "~", removed = "-" },
      },
    },
    lualine_x = {
      {
        "diagnostics",
        sources = { "nvim_lsp" },
        symbols = { error = "E", warn = "W", info = "I", hint = "H" },
      },
      "filetype",
    },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
})
