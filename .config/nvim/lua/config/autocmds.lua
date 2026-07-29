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
  group = augroup("term_keymaps"),
  callback = function(ev)
    -- Buffer-local, so full-screen TUIs can opt out: a global <esc><esc> would swallow
    -- Esc (and make a lone Esc wait out timeoutlen) inside any modal terminal app.
    if vim.api.nvim_buf_get_name(ev.buf):match("tuicr") then
      return
    end
    local map = function(lhs, rhs, o)
      o.buffer = ev.buf
      vim.keymap.set("t", lhs, rhs, o)
    end
    map("<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
    map("<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Go to Left Window/Pane" })
    map("<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Go to Lower Window/Pane" })
    map("<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Go to Upper Window/Pane" })
    map("<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Go to Right Window/Pane" })
    map("<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })
  end,
})

