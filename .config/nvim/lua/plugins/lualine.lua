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
        symbols = { modified = "\239\131\135 ", readonly = "\239\128\163 ", unnamed = "[No Name]" },
      },
    },
    lualine_c = {
      {
        "branch",
        icon = { "\238\156\165", align = "left" },
      },
      {
        "diff",
        symbols = { added = "+", modified = "~", removed = "-" },
      },
      {
        function()
          return "\226\151\143 @" .. vim.fn.reg_recording()
        end,
        cond = function()
          return vim.fn.reg_recording() ~= ""
        end,
      },
    },
    lualine_x = {
      "lsp_status",
      {
        "diagnostics",
        sources = { "nvim_lsp" },
        symbols = { error = "E", warn = "W", info = "I", hint = "H" },
      },
      "filetype",
    },
    lualine_y = { "progress" },
    lualine_z = { "selectioncount", "location", "searchcount" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  extensions = { "oil" },
})
