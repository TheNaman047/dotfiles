vim.pack.add({
  "https://github.com/akinsho/toggleterm.nvim.git",
})

require("toggleterm").setup({
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  open_mapping = false,
  hide_numbers = true,
  shade_terminals = true,
  shading_factor = 2,
  start_in_insert = true,
  insert_mappings = false,
  terminal_mappings = false,
  persist_size = true,
  persist_mode = true,
  direction = "float",
  close_on_exit = true,
  shell = vim.o.shell,
  auto_scroll = false,
  winbar = {
    enabled = false,
    name_formatter = function(term)
      return term.name
    end
  },
})

-- Track active terminals
local active_terminals = {}

local function new_terminal()
  local id = #active_terminals + 1
  -- Find next available ID
  while active_terminals[id] do
    id = id + 1
  end
  active_terminals[id] = true
  vim.cmd(string.format("ToggleTerm %d size=15 direction=horizontal", id))
end

local function has_active_terminals()
  for _ in pairs(active_terminals) do
    return true
  end
  return false
end

local function toggle_or_create()
  if not has_active_terminals() then
    new_terminal()
  else
    vim.cmd("ToggleTermToggleAll")
  end
end

-- Clean up when terminal is closed
vim.api.nvim_create_autocmd("TermClose", {
  pattern = "term://*toggleterm#*",
  callback = function()
    -- Extract terminal ID from buffer name
    local bufname = vim.api.nvim_buf_get_name(0)
    local id = bufname:match("toggleterm#(%d+)")
    if id then
      active_terminals[tonumber(id)] = nil
    end
  end,
})

-- Create new terminal
vim.keymap.set("n", "<leader>nt", new_terminal, { desc = "New terminal" })
vim.keymap.set("t", "<leader>nt", new_terminal, { desc = "New terminal" })

-- Toggle all or create first (normal mode only)
vim.keymap.set("n", "<leader>t", toggle_or_create, { desc = "Toggle all terminals" })

