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

-- Setting theme
vim.pack.add({
  { src = "https://github.com/vague2k/vague.nvim" },
  { src = "https://github.com/rose-pine/neovim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/refractalize/oil-git-status.nvim" },
  { src = "https://github.com/echasnovski/mini.pick" },
  { src = "https://github.com/echasnovski/mini.pairs" },
  { src = "https://github.com/saghen/blink.cmp", version = "v1.8.0" },
  { src = "https://github.com/echasnovski/mini.snippets" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/kristijanhusak/vim-dadbod-ui" },
  { src = "https://github.com/tpope/vim-dadbod" },
  { src = "https://github.com/kristijanhusak/vim-dadbod-completion" },
  { src = "https://github.com/christoomey/vim-tmux-navigator" },
  { src = "https://github.com/ibhagwan/smartyank.nvim" },
  { src = "https://github.com/smithbm2316/centerpad.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/olimorris/codecompanion.nvim" },
  { src = "https://github.com/ravitemer/codecompanion-history.nvim" },
  { src = "https://github.com/coder/claudecode.nvim" },
  { src = "https://github.com/adriankarlen/plugin-view.nvim" },
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
  keymap = {preset = 'super-tab'},
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
require "claudecode".setup()
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

-- Setup terminal module
local terminal = require("term")
terminal.setup()
-- Setup terminal module
local dadbod_ui = require("db")
dadbod_ui.setup()

-- Set colorscheme
-- vim.cmd("colorscheme vague")
vim.cmd("colorscheme rose-pine")
vim.cmd(":hi statusline guibg=NONE")

-- Enable lsp
vim.lsp.enable({ "ts_ls", "lua_ls", "vtsls", "vue_ls", "jsonls", "basedpyright", "ruff" })

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

-- Terminal keymaps
vim.keymap.set("n", "<leader>t", function() terminal.create_terminal("horizontal") end,
  { noremap = true, silent = true })
vim.keymap.set("n", "<leader>x", function() terminal.close_terminal("horizontal") end,
  { noremap = true, silent = true })

-- ClaudeCode
vim.keymap.set("n", "<leader>c", "<cmd>ClaudeCode<cr>", opts)
vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", opts)
vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", opts)

-- Code Companion keymaps
vim.keymap.set({ "n", "v" }, "<leader>i", "<cmd>CodeCompanionChat Toggle<cr>", opts)
vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", opts)
vim.keymap.set({ "n", "v" }, "<leader>ah", "<cmd>CodeCompanionHistory<cr>", opts)
vim.keymap.set("v", "<leader>ap", "<cmd>CodeCompanionChat Add<cr>", opts)

-- Centerpad keymap
vim.api.nvim_set_keymap('n', '<leader>z', '<cmd>Centerpad<cr>', opts)

-- Navigate between splits and tmux panes
-- Use ctrl-[hjkl] to select the active split!
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", opts)
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", opts)
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", opts)
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", opts)
vim.keymap.set("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", opts)

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

require('statusline')
