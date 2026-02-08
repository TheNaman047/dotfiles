local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Source current file to nvim
map("n", "<leader>o", ":update<CR> :source<CR>", opts)

-- Split resize maps
-- Vertical resize
map("n", "<S-Left>", "<C-W>15<", opts)
map("n", "<S-Right>", "<C-W>15>", opts)
-- Horizontal resize
map("n", "<S-Down>", "<C-W>10-", opts) -- Decrease height
map("n", "<S-Up>", "<C-W>10+", opts)   -- Increase height

-- Quickfix and location lists
map("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location List" })

map("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })


-- Toggle line wrapping
map("n", "<leader>xw", "<cmd>set wrap!<CR>", { desc = "Toggle Wrap", silent = true })

-- Miscellaneous
-- Generate uuid at cursor
map("n", "<leader>guu", ":r !uuidgen<CR>", opts)
-- map("n", "<leader>gp", utils.copy_file_path, opts)
