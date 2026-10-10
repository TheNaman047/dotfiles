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
    vim.opt_local.spell = false
    vim.opt_local.cursorline = false
    vim.opt_local.colorcolumn = ""

    local map = function(lhs, rhs, o)
      o.buffer = ev.buf
      vim.keymap.set("t", lhs, rhs, o)
    end
    -- Buffer-local, so Esc-heavy TUIs can opt out: <esc><esc> makes every lone Esc wait
    -- out timeoutlen (~1s) before the app sees it. Use <C-\><C-n> there instead.
    -- Match the executable only: the name is term://<cwd>//<pid>:<cmd>, and paths may contain "claude"
    local cmd = vim.api.nvim_buf_get_name(ev.buf):match("//%d+:(%S+)") or ""
    local exe = vim.fs.basename(cmd)
    if exe ~= "claude" and exe ~= "lazygit" then
      map("<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
    end
    if exe == "claude" then
      vim.api.nvim_create_autocmd("BufEnter", {
        buffer = ev.buf,
        -- Scheduled + rechecked: a window hop that passes through would otherwise land insert mode elsewhere
        callback = function()
          vim.schedule(function()
            if vim.api.nvim_get_current_buf() == ev.buf then vim.cmd.startinsert() end
          end)
        end,
      })
    end
    map("<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Go to Left Window/Pane" })
    map("<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Go to Lower Window/Pane" })
    map("<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Go to Upper Window/Pane" })
    map("<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Go to Right Window/Pane" })
    map("<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })
  end,
})

