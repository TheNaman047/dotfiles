
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " " 
vim.g.maplocalleader = "\\"

-- Navigate between splits
-- Use ctrl-[hjkl] to select the active split!
vim.cmd("nmap <silent> <c-k> :wincmd k<CR>")
vim.cmd("nmap <silent> <c-j> :wincmd j<CR>")
vim.cmd("nmap <silent> <c-h> :wincmd h<CR>")
vim.cmd("nmap <silent> <c-l> :wincmd l<CR>")
