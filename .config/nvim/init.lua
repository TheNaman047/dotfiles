-- Set good to have options
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.number = true
vim.o.relativenumber = true
vim.o.swapfile = false
vim.o.signcolumn = "yes"
vim.o.winborder = "rounded"
vim.o.hidden = true
vim.o.showmode = true
vim.o.scrolloff = 1
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.autoread = true
vim.o.cursorline = true
vim.o.splitbelow = true
vim.o.splitright = true

-- Set leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Set 24bit color
vim.o.termguicolors = true

-- Setting theme
vim.pack.add({
  { src = "https://github.com/vague2k/vague.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/refractalize/oil-git-status.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/echasnovski/mini.pick" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/echasnovski/mini.pairs" },
})

-- Enable lsp
vim.lsp.enable({ "lua_ls", "ts_ls" })
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
    if client:supports_method('textDocument/completion') then
      -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})
vim.cmd("set completeopt+=noselect")

-- Setup plugins
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

-- Set colorscheme
vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

local opts = { noremap = true, silent = true }
-- Source current file to nvim
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>", opts)

-- LSP keymaps
vim.keymap.set("n", "<leader>fd", vim.lsp.buf.format, opts)


-- Oil keymaps
vim.keymap.set("n", "-", "<CMD>Oil<CR>", opts)
vim.keymap.set("n", "<leader>-", "<CMD>Oil --float<CR>", opts)

-- Mini pick functions
-- Remove the buffer and move to the next file
local wipeout_cur_buf = function()
  local current_match = MiniPick.get_picker_matches().current
  vim.api.nvim_buf_delete(current_match.bufnr, {})
  -- Refresh the picker to update the buffer list
  MiniPick.set_picker_items(vim.tbl_filter(function(item)
    return vim.api.nvim_buf_is_valid(item.bufnr)
  end, MiniPick.get_picker_items()))
end
local buffer_mappings = { wipeout = { char = '<C-d>', func = wipeout_cur_buf } }
local local_opts = { include_current = false }
-- MiniPick.builtin.buffers(local_opts, { mappings = buffer_mappings })

-- Mini pick keymap
vim.keymap.set("n", "<leader>p", ":Pick files<CR>", opts)
vim.keymap.set("n", "<leader>gf", ":Pick grep<CR>", opts)
vim.keymap.set("n", "<leader>gb", function()
  MiniPick.builtin.buffers(local_opts, { mappings = buffer_mappings })
end, opts)
vim.keymap.set("n", "<leader>l", ":Pick grep_live<CR>", opts)
vim.keymap.set("n", "<leader>r", ":Pick resume<CR>", opts)
vim.keymap.set("n", "<leader>h", ":Pick help<CR>", opts)

-- Navigate between splits
-- Use ctrl-[hjkl] to select the active split!
vim.keymap.set("n", "<C-k>", ":wincmd k<CR>", opts)
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>", opts)
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>", opts)
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>", opts)

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
