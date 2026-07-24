vim.pack.add({
  { src = "https://github.com/folke/lazydev.nvim", version = "v1.10.0" },
})

require('lazydev').setup({
  library = {
    -- Load luvit types when the `vim.uv` word is found
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})
