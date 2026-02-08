local opt = vim.opt
-- Set good to have options
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.scrolloff = 5
opt.spell = true

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

opt.termguicolors = true
opt.signcolumn = "yes"
opt.showmatch = true
opt.matchtime = 4
opt.cmdheight = 1
opt.showmode = false
opt.pumheight = 10
opt.winblend = 0
opt.conceallevel = 2
opt.confirm = true
opt.concealcursor = ""
opt.synmaxcol = 300
opt.ruler = false
opt.colorcolumn = "100"
opt.winborder = "rounded"

opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.undolevels = 10000
opt.undodir = vim.fn.expand("~/.vim/undodir")
opt.updatetime = 300
opt.autoread = true

opt.hidden = true
opt.errorbells = false
opt.backspace = "indent,eol,start"
opt.autochdir = false
opt.iskeyword:append("-")
opt.path:append("**")
opt.selection = "exclusive"
opt.mouse = "a"
opt.encoding = "UTF-8"

opt.smoothscroll = true
vim.wo.foldmethod = "expr"
opt.foldlevel = 99
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"

opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

opt.wildmenu = true
opt.wildmode = "longest:full,full"

opt.diffopt:append("linematch:60")

opt.redrawtime = 10000
opt.maxmempattern = 20000

-- Create undo directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end

vim.g.trouble_lualine = true

opt.jumpoptions = "view"
opt.laststatus = 3
opt.list = false
opt.linebreak = true
opt.list = true
opt.shiftround = true
opt.shiftwidth = 2
opt.shortmess:append({ W = true, I = true, c = true, C = true})

vim.g.markdown_recommended_style = 0

opt.fillchars = {
  foldopen = " ",
  foldclose = " ",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

vim.filetype.add({
  extension = {
    env = "dotenv",
  },
  filename = {
    [".env"] = "dotenv",
    ["env"] = "dotenv",
  },
  pattern = {
    ["[jt]sconfig.*.json"] = "jsonc",
    ["%.env%.[%w_.-]+"] = "dotenv",
  }
})

-- vim.o.acd = true
