local Utils = require ("../utils/functions")

-- Set good to have options
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.cmd("set relativenumber")
vim.cmd("set hidden")
vim.cmd("set noshowmode")
vim.cmd("set scrolloff=1")
vim.cmd("set ignorecase")
vim.cmd("set smartcase")
vim.cmd("set autoread")
vim.cmd("set autowriteall")
vim.cmd("set cursorline")
vim.cmd("set splitbelow splitright")

-- Set leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Set 24bit color
vim.opt.termguicolors = true

-- Navigate between splits
-- Use ctrl-[hjkl] to select the active split!
vim.keymap.set("n", "<C-k>", ":wincmd k<CR>", Utils.opts)
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>", Utils.opts)
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>", Utils.opts)
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>", Utils.opts)

-- Toggle relative line numbering
vim.keymap.set("n", "<leader>r", ":set relativenumber!<CR>", Utils.opts)

-- Set Esc key to leave terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", Utils.opts)

-- Set buffer keymaps
-- Bufferline close tab
vim.keymap.set("n", "gjd", ":Bdelete<CR>", Utils.MergeTables(Utils.opts, { desc = "Bufferline close tab" }))

-- Bufferline close buffer
vim.keymap.set("n", "gjx", ":bd<CR>", Utils.MergeTables(Utils.opts, { desc = "Bufferline close buffer" }))

-- Bufferline save buffer
-- vim.keymap.set("n", "gjs", ":w<CR>", Utils.MergeTables(Utils.opts, { desc = "Bufferline save buffer" }))

-- Generate uuid at cursor
vim.keymap.set("n", "guu", ":r !uuidgen<CR>", Utils.MergeTables(Utils.opts, { desc = "Generate uuid at cursor" }))

-- Split resize maps
-- Vertical resize
vim.keymap.set("n", "<S-Left>", "<C-W>15<", Utils.opts)
vim.keymap.set("n", "<S-Right>", "<C-W>15>", Utils.opts)
-- Horizontal resize
vim.keymap.set("n", "<S-Down>", "<C-W>10-", Utils.opts) -- Decrease height
vim.keymap.set("n", "<S-Up>", "<C-W>10+", Utils.opts) -- Increase height
