local augroup = require("utils").augroup

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})


-- Set filetype for .toml files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("toml_filetype"),
  pattern = { "*.tomg-config*" },
  callback = function()
    vim.opt_local.filetype = "toml"
  end,
})


vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    local map = vim.keymap.set
    map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
    map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window" })
    map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to Lower Window" })
    map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to Upper Window" })
    map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to Right Window" })
    map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })
  end,
})

