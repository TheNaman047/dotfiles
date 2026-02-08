-- Set good to have options
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.number = true
vim.o.relativenumber = true
vim.o.swapfile = false
vim.o.signcolumn = "yes"
vim.o.colorcolumn = "100"
vim.o.winborder = "rounded"
vim.o.hidden = true
vim.o.showmode = false
vim.o.scrolloff = 1
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.autoread = true
vim.o.cursorline = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.spell = true
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.redrawtime = 10000
vim.o.maxmempattern = 20000

-- vim.o.acd = true
-- Set leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Set 24bit color
vim.o.termguicolors = true

-- OpenCode config
vim.g.opencode_opts = {
  provider = {
    enabled = "terminal",
  }
}

-- Setting theme
vim.pack.add({
  "https://github.com/vague2k/vague.nvim",
  "https://github.com/rose-pine/neovim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/refractalize/oil-git-status.nvim",
  "https://github.com/echasnovski/mini.pick",
  "https://github.com/echasnovski/mini.pairs",
  { src = "https://github.com/saghen/blink.cmp", version = "v1.8.0" },
  "https://github.com/echasnovski/mini.snippets",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/kristijanhusak/vim-dadbod-ui",
  "https://github.com/tpope/vim-dadbod",
  "https://github.com/kristijanhusak/vim-dadbod-completion",
  "https://github.com/christoomey/vim-tmux-navigator",
  "https://github.com/ibhagwan/smartyank.nvim",
  "https://github.com/smithbm2316/centerpad.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/olimorris/codecompanion.nvim",
  "https://github.com/ravitemer/codecompanion-history.nvim",
  "https://github.com/coder/claudecode.nvim",
  "https://github.com/NickvanDyke/opencode.nvim",
  "https://github.com/adriankarlen/plugin-view.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/vuki656/package-info.nvim",
  "https://github.com/folke/snacks.nvim",
})

-- Imports and declarations
local opts = { noremap = true, silent = true }
local utils = require('utils')

-- Setup plugins
require "vague".setup({ transparent = true })
require "oil".setup({
  win_options = {
    signcolumn = "yes:2",
  },
  delete_to_trash = true,
  view_options = {
    show_hidden = true,
  },
  keymaps = {
    ["<C-t>"] = { "actions.select", opts = { tab = true } },
    ["<C-r>"] = { "actions.preview", opts = { split = "botright" } },
    ["<C-p>"] = false,
    ["g."] = { "actions.toggle_hidden", mode = "n" },
  },
})
require "mini.pick".setup({ options = { use_cache = true } })
require "mini.pairs".setup()
require "plugin-view".setup({})
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
require "package-info".setup({})

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
    -- Load snippets based on current language by reading files from
    -- "snippets/" subdirectories from 'runtimepath' directories.
    gen_loader.from_lang(),
  },
})
require "smartyank".setup()
require "rose-pine".setup({
  styles = {
    transparency = true,
  },
  dim_inactive_windows = true
})
require 'nvim-treesitter.configs'.setup({
  ensure_installed = { "lua", "vim", "vimdoc", "markdown", "markdown_inline", "javascript", "typescript", "json", "python", "toml", "rust", "sql", "tsx", "yaml", "dockerfile", "terraform", "hcl", },
  highlight = { enable = true }
})
-- require "claudecode".setup({
--   terminal = {
--     provider = "none", -- no UI actions; server + tools remain available
--   },
-- })
require "codecompanion".setup({
  display = { chat = { window = { width = 0.4, } } },
  strategies = {
    chat = {
      adapter = "anthropic",
      model = "claude-sonnet-4.5",
      auto_scroll = false,
    },
  },
  extensions = { history = { enabled = true } }
})

-- Configure snacks.nvim terminal behavior
require("snacks").setup({
  styles = {
    bo = {
      filetype = "snacks_terminal",
    },
    wo = {},
    stack = true, -- when enabled, multiple split windows with the same position will be stacked together (useful for terminals)
    keys = {
      q = "hide",
      gf = function(self)
        local f = vim.fn.findfile(vim.fn.expand("<cfile>"), "**")
        if f == "" then
          Snacks.notify.warn("No file under cursor")
        else
          self:hide()
          vim.schedule(function()
            vim.cmd("e " .. f)
          end)
        end
      end,
      term_normal = {
        "<esc>",
        function(self)
          self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
          if self.esc_timer:is_active() then
            self.esc_timer:stop()
            vim.cmd("stopinsert")
          else
            self.esc_timer:start(200, 0, function() end)
            return "<esc>"
          end
        end,
        mode = "t",
        expr = true,
        desc = "Double escape to normal mode",
      },
    },
  },
  terminal = {
    auto_close = true,
    start_insert = true,
    interactive = true,
    -- win = {
    --   style = "terminal",
    --   keys = {
    --     -- Navigation keymaps for terminal mode
    --     nav_h = { "<C-h>", [[<C-[><C-[><C-w>h]], mode = "t", desc = "Go to Left Window" },
    --     nav_j = { "<C-j>", [[<C-[><C-[><C-w>j]], mode = "t", desc = "Go to Lower Window" },
    --     nav_k = { "<C-k>", [[<C-[><C-[><C-w>k]], mode = "t", desc = "Go to Upper Window" },
    --     nav_l = { "<C-l>", [[<C-[><C-[><C-w>l]], mode = "t", desc = "Go to Right Window" },
    --     nav_p = { "<C-\\>", [[<C-[><C-[><C-w>p]], mode = "t", desc = "Go to Previous Window" },
    --   },
    -- },
  },
})

-- Setup dadbod module
local dadbod_ui = require("db")
dadbod_ui.setup()

-- Set colorscheme
-- vim.cmd("colorscheme vague")
vim.cmd("colorscheme rose-pine")
vim.cmd(":hi statusline guibg=NONE")

-- Enable lsp
vim.lsp.enable({ "ts_go_ls", "lua_ls", "vtsls", "vue_ls", "jsonls", "basedpyright", "ruff" })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client.name == 'ruff' then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end
  end,
})

-- Source current file to nvim
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>", opts)

-- LSP keymaps
vim.keymap.set("n", "<leader>fd", vim.lsp.buf.format, opts)

-- Oil keymaps
vim.keymap.set("n", "-", "<CMD>Oil<CR>", opts)
vim.keymap.set("n", "<leader>-", "<CMD>Oil --float<CR>", opts)

-- Plugin View keymaps
vim.keymap.set("n", "<leader>v", require("plugin-view").open, opts)

-- Mini pick keymap
local mini_pick = require("mini-pick")
local buffer_mappings = { wipeout = { char = '<C-d>', func = mini_pick.wipeout_cur_buf } }
local local_opts = { include_current = false }
vim.keymap.set("n", "<leader>p", mini_pick.pick_with_hidden, opts)
vim.keymap.set("n", "<leader>gf", ":Pick grep<CR>", opts)
vim.keymap.set("n", "<leader>gb", function()
  MiniPick.builtin.buffers(local_opts, { mappings = buffer_mappings })
end, opts)
vim.keymap.set("n", "<leader>l", ":Pick grep_live<CR>", opts)
vim.keymap.set("n", "<leader>r", ":Pick resume<CR>", opts)
vim.keymap.set("n", "<leader>h", ":Pick help<CR>", opts)

-- Dadbod keymaps
vim.keymap.set("n", "<leader>d", ":DBUIToggle<CR>", opts)

-- Terminal keymaps (simplified)
vim.keymap.set("n", "<leader>t", function() require("snacks").terminal.toggle() end,
  { noremap = true, silent = true, desc = "Toggle terminal" })
vim.keymap.set("n", "<leader>x", function()
    require("snacks").terminal.toggle(nil, {
      win = {
        position = "right",
        width = 0.4
      }
    })
  end,
  { noremap = true, silent = true, desc = "Toggle vertical terminal" })

-- ClaudeCode
-- vim.keymap.set("n", "<leader>c", "<cmd>ClaudeCode<cr>", opts)
-- vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", opts)
-- vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", opts)

-- OpenCode
vim.keymap.set({ "n", "x" }, "<leader>er", function() return require("opencode").operator("@this ") end,
  { desc = "Add range to opencode", expr = true })
vim.keymap.set("n", "<leader>ef", function() return require("opencode").operator("@this ") .. "_" end,
  { desc = "Add line to opencode", expr = true })

-- Code Companion keymaps
vim.keymap.set({ "n", "v" }, "<leader>i", "<cmd>CodeCompanionChat Toggle<cr>", opts)
vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", opts)
vim.keymap.set({ "n", "v" }, "<leader>ah", "<cmd>CodeCompanionHistory<cr>", opts)
vim.keymap.set("v", "<leader>ap", "<cmd>CodeCompanionChat Add<cr>", opts)

-- Centerpad keymap
vim.api.nvim_set_keymap('n', '<leader>z', '<cmd>Centerpad<cr>', opts)


-- Package Info keymap
vim.api.nvim_set_keymap('n', '<leader>ns', '<cmd>lua require("package-info").show()<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>np', '<cmd>lua require("package-info").change_version()<cr>', opts)

-- Navigate between splits and tmux panes
-- Use ctrl-[hjkl] to select the active split!
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })

-- Split resize maps
-- Vertical resize
vim.keymap.set("n", "<S-Left>", "<C-W>15<", opts)
vim.keymap.set("n", "<S-Right>", "<C-W>15>", opts)
-- Horizontal resize
vim.keymap.set("n", "<S-Down>", "<C-W>10-", opts) -- Decrease height
vim.keymap.set("n", "<S-Up>", "<C-W>10+", opts)   -- Increase height

-- Miscellaneous
-- Generate uuid at cursor
vim.keymap.set("n", "<leader>guu", ":r !uuidgen<CR>", opts)
vim.keymap.set("n", "<leader>gp", utils.copy_file_path, opts)

vim.o.autochdir = false

-- require('statusline')
