vim.pack.add({
  "https://github.com/echasnovski/mini.pairs",
  "https://github.com/echasnovski/mini.snippets",
})

require "mini.pairs".setup()

local gen_loader = require('mini.snippets').gen_loader
require('mini.snippets').setup({
  mappings = {
    expand = '<C-e>',
    jump_next = '<C-j>',
    jump_prev = '<C-k>',
    stop = '<C-c>',
  },
  snippets = {
    gen_loader.from_file('~/.config/nvim/snippets/global.json'),
    gen_loader.from_lang(),
  },
})
