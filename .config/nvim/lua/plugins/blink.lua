vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = "v1.9.1" },
})

require('blink.cmp').setup({
  keymap = { preset = 'super-tab' },
  snippets = { preset = 'mini_snippets' },
  completion = {
    accept = {
      auto_brackets = {
        enabled = true,
      },
    },
    menu = {
      draw = {
        treesitter = { "lsp" },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    per_filetype = {
      sql = { 'snippets', 'dadbod', 'buffer' },
    },
    providers = {
      dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
    },
  },
})
