local M = {}

-- Store terminal states
M.terminals = {
  horizontal = { buf = nil, win = nil },
  vertical = { buf = nil, win = nil },
  float = { buf = nil, win = nil }
}

-- Check if a window is valid and visible
local function is_win_valid(win)
  return win and vim.api.nvim_win_is_valid(win)
end

-- Check if a buffer is valid and is a terminal
local function is_term_buf_valid(buf)
  return buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal"
end

-- Create terminal in different directions
function M.create_terminal(direction, size)
  local term = M.terminals[direction]

  -- If terminal window is open, close it
  if is_win_valid(term.win) then
    vim.api.nvim_win_close(term.win, false)
    term.win = nil
    return
  end

  -- Create new terminal if buffer doesn't exist or is invalid
  if not is_term_buf_valid(term.buf) then
    term.buf = vim.api.nvim_create_buf(false, true)
  end

  if direction == "horizontal" then
    vim.cmd("split")
    local height = size or math.floor(vim.o.lines * 0.3)
    vim.api.nvim_win_set_height(0, height)
    term.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(term.win, term.buf)

    -- Only start terminal if buffer is empty (new)
    if vim.api.nvim_buf_line_count(term.buf) == 1 and vim.api.nvim_buf_get_lines(term.buf, 0, 1, false)[1] == "" then
      vim.fn.termopen(vim.o.shell)
    end
  elseif direction == "vertical" then
    vim.cmd("vsplit")
    local width = size or math.floor(vim.o.columns * 0.4)
    vim.api.nvim_win_set_width(0, width)
    term.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(term.win, term.buf)

    -- Only start terminal if buffer is empty (new)
    if vim.api.nvim_buf_line_count(term.buf) == 1 and vim.api.nvim_buf_get_lines(term.buf, 0, 1, false)[1] == "" then
      vim.fn.termopen(vim.o.shell)
    end
  elseif direction == "float" then
    local width = size and size.width or math.floor(vim.o.columns * 0.8)
    local height = size and size.height or math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win_config = {
      relative = "editor",
      row = row,
      col = col,
      width = width,
      height = height,
      style = "minimal",
      border = "rounded"
    }
    term.win = vim.api.nvim_open_win(term.buf, true, win_config)

    -- Only start terminal if buffer is empty (new)
    if vim.api.nvim_buf_line_count(term.buf) == 1 and vim.api.nvim_buf_get_lines(term.buf, 0, 1, false)[1] == "" then
      vim.fn.termopen(vim.o.shell)
    end
  end

  vim.cmd("startinsert")
end

-- Setup terminal configuration and autocmds
function M.setup()
  -- Terminal buffer settings
  vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function()
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.signcolumn = "no"
    end,
  })

  -- Auto enter insert mode when switching to terminal
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "term://*",
    callback = function()
      vim.cmd("startinsert")
    end,
  })

  -- Close terminal window when process exits
  vim.api.nvim_create_autocmd("TermClose", {
    pattern = "*",
    callback = function(event)
      local buf = event.buf

      -- Find which terminal this buffer belongs to and clean up
      for direction, term in pairs(M.terminals) do
        if term.buf == buf then
          if is_win_valid(term.win) then
            vim.api.nvim_win_close(term.win, false)
          end
          term.buf = nil
          term.win = nil
          break
        end
      end

      -- Schedule buffer deletion to avoid issues
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end)
    end,
  })

  -- Exit terminal mode with Esc
  vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })

  -- Terminal navigation (while in terminal mode)
  vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
  vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
  vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
  vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })

  -- Normal mode navigation (consistent with terminal)
  vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
  vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
  vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
  vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })
end

return M
