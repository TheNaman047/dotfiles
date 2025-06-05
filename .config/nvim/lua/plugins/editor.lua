local vimTmuxNavigator = {
  "christoomey/vim-tmux-navigator",
  event = "VeryLazy",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
    { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
    { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
    { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
}

local smartyank = {
  "ibhagwan/smartyank.nvim",
  event = "VeryLazy",
  config = function()
    local config = require("smartyank")
    config.setup({
      highlight = {
        enabled = true,        -- highlight yanked text
        higroup = "IncSearch", -- highlight group of yanked text
        timeout = 500,         -- timeout for clearing the highlight
      },
      clipboard = {
        enabled = true,
      },
      tmux = {
        enabled = true,
        -- remove `-w` to disable copy to host client's clipboard
        cmd = { "tmux", "set-buffer", "-w" },
      },
      osc52 = {
        enabled = true,
        escseq = "tmux",       -- use tmux escape sequence, only enable if
        -- you're using tmux and have issues (see #4)
        ssh_only = true,       -- false to OSC52 yank also in local sessions
        silent = false,        -- true to disable the "n chars copied" echo
        echo_hl = "Directory", -- highlight group of the OSC52 echo message
      },
    })
  end,
}

local typr = {
  "nvzone/typr",
  dependencies = "nvzone/volt",
  opts = {
  },
  cmd = { "Typr", "TyprStats" },
}

local distant = {
  'chipsenkbeil/distant.nvim',
  branch = 'v0.3',
  config = function()
    require('distant'):setup()
  end
}

return {
  vimTmuxNavigator,
  smartyank,
  typr,
  distant
}
