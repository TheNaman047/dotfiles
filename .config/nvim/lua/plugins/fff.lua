vim.pack.add({
  "https://github.com/dmtrKovalenko/fff.nvim",
})

-- Download/build the native binary after install or update
vim.api.nvim_create_autocmd("User", {
  pattern = "PackChanged",
  callback = function(ev)
    local name = ev.data and ev.data.spec and ev.data.spec.name
    local kind = ev.data and ev.data.kind
    if name == "fff.nvim" and (kind == "install" or kind == "update") then
      if not ev.data.active then
        vim.cmd.packadd("fff.nvim")
      end
      require("fff.download").download_or_build_binary()
    end
  end,
})

require("fff").setup({
  layout = {
    height = 0.8,
    width = 0.8,
    prompt_position = "bottom",
    preview_position = "right",
    preview_size = 0.45,
  },
  frecency = { enabled = true },
  git = { status_text_color = false },
  grep = { smart_case = true },
})

vim.keymap.set("n", "<leader>p", function() require("fff").find_files() end, { desc = "Find files" })
vim.keymap.set("n", "<leader>gf", function() require("fff").grep() end, { desc = "Grep" })
vim.keymap.set("n", "<leader>l", function() require("fff").grep() end, { desc = "Live grep" })
