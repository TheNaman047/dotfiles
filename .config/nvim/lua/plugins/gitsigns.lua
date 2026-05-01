vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
})

local gitsigns = require("gitsigns")

gitsigns.setup({
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "󰍵" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "│" },
  },
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol",
    delay = 1000,
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    vim.keymap.set("n", "]h", function()
      if vim.wo.diff then
        return "]h"
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return "<Ignore>"
    end, { buffer = bufnr, desc = "Next hunk", expr = true })

    vim.keymap.set("n", "[h", function()
      if vim.wo.diff then
        return "[h"
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return "<Ignore>"
    end, { buffer = bufnr, desc = "Prev hunk", expr = true })

    map({ "n", "v" }, "<leader>hs", gs.stage_hunk, "Stage hunk")
    map({ "n", "v" }, "<leader>hr", gs.reset_hunk, "Reset hunk")
    map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
    map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
    map("n", "<leader>hp", gs.preview_hunk_inline, "Preview hunk")
    map("n", "<leader>hb", gs.blame_line, "Blame line")
    map("n", "<leader>hd", gs.diffthis, "Diff this")
    map("n", "<leader>htb", gs.toggle_current_line_blame, "Toggle blame")
  end,
})