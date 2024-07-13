-- Function to merge two tables
function mergeTables(t1, t2)
	local merged = {}
	for k, v in pairs(t1) do
		merged[k] = v
	end
	for k, v in pairs(t2) do
		merged[k] = v
	end
	return merged
end

-- Set common opts
local opts = { noremap = true, silent = true }

-- Set good to have options
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.cmd("set relativenumber")
vim.cmd("set hidden")

-- Set leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Set 24bit color
vim.opt.termguicolors = true

-- Navigate between splits
-- Use ctrl-[hjkl] to select the active split!
vim.keymap.set("n", "<C-k>", ":wincmd k<CR>", opts)
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>", opts)
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>", opts)
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>", opts)

-- Toggle relative line numbering
vim.keymap.set("n", "<leader>r", ":set relativenumber!<CR>", opts)

-- Set Esc key to leave terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)

-- Set buffer keymaps
-- Bufferline close tab
vim.keymap.set("n", "gjd", ":Bdelete<CR>", mergeTables(opts, { desc = "Bufferline close tab" }))

-- Bufferline close buffer
vim.keymap.set("n", "gjx", ":bd<CR>", mergeTables(opts, { desc = "Bufferline close buffer" }))

-- Bufferline save buffer
vim.keymap.set("n", "gjs", ":w<CR>", mergeTables(opts, { desc = "Bufferline save buffer" }))
