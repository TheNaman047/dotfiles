local M = {}

-- Store terminal states with additional metadata
M.terminals = {
  horizontal = { buf = nil, win = nil, job_id = nil },
  vertical = { buf = nil, win = nil, job_id = nil },
  float = { buf = nil, win = nil, job_id = nil }
}

-- Default configuration
M.config = {
  horizontal = {
    size = 0.3, -- 30% of screen height
    position = "bottom"
  },
  vertical = {
    size = 0.4, -- 40% of screen width
    position = "right"
  },
  float = {
    width = 0.8,  -- 80% of screen width
    height = 0.8, -- 80% of screen height
    border = "rounded"
  },
  shell = vim.o.shell,
  auto_close = true,
  start_in_insert = true
}

-- Check if a window is valid and visible
local function is_win_valid(win)
  return win and vim.api.nvim_win_is_valid(win)
end

-- Check if a buffer is valid and is a terminal
local function is_term_buf_valid(buf)
  return buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal"
end

-- Helper function to start terminal process
local function start_terminal_process(buf, shell)
  local job_id = vim.fn.termopen(shell or M.config.shell)
  return job_id
end

-- Create terminal in different directions
function M.create_terminal(direction, opts)
  if not M.terminals[direction] then
    vim.notify("Invalid terminal direction: " .. direction, vim.log.levels.ERROR)
    return
  end

  local term = M.terminals[direction]
  opts = opts or {}

  -- If terminal window is open, close it (toggle behavior)
  if is_win_valid(term.win) then
    vim.api.nvim_win_close(term.win, false)
    term.win = nil
    return
  end

  -- Create new terminal if buffer doesn't exist or is invalid
  if not is_term_buf_valid(term.buf) then
    term.buf = vim.api.nvim_create_buf(false, true)
    -- Set buffer name for better identification
    vim.api.nvim_buf_set_name(term.buf, "Terminal-" .. direction)
  end

  local config = M.config[direction]

  if direction == "horizontal" then
    if config.position == "top" then
      vim.cmd("topleft split")
    else
      vim.cmd("botright split")
    end
    local height = opts.size or math.floor(vim.o.lines * config.size)
    vim.api.nvim_win_set_height(0, height)
  elseif direction == "vertical" then
    if config.position == "left" then
      vim.cmd("topleft vsplit")
    else
      vim.cmd("botright vsplit")
    end
    local width = opts.size or math.floor(vim.o.columns * config.size)
    vim.api.nvim_win_set_width(0, width)
  elseif direction == "float" then
    local width = opts.width or math.floor(vim.o.columns * config.width)
    local height = opts.height or math.floor(vim.o.lines * config.height)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win_config = {
      relative = "editor",
      row = row,
      col = col,
      width = width,
      height = height,
      style = "minimal",
      border = opts.border or config.border,
      title = " Terminal ",
      title_pos = "center"
    }
    term.win = vim.api.nvim_open_win(term.buf, true, win_config)
    vim.api.nvim_win_set_buf(term.win, term.buf)

    -- Set window-specific options for floating terminal
    vim.api.nvim_set_option_value("winhl", "Normal:Normal,FloatBorder:FloatBorder", { win = term.win })

    if M.config.start_in_insert then
      vim.cmd("startinsert")
    end
    return
  end

  -- For horizontal and vertical terminals
  term.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(term.win, term.buf)

  -- Only start terminal if buffer is empty (new terminal)
  local is_empty = vim.api.nvim_buf_line_count(term.buf) == 1 and
      vim.api.nvim_buf_get_lines(term.buf, 0, 1, false)[1] == ""

  if is_empty then
    term.job_id = start_terminal_process(term.buf, opts.shell)
  end

  if M.config.start_in_insert then
    vim.cmd("startinsert")
  end
end

-- Send command to terminal
function M.send_command(direction, cmd)
  local term = M.terminals[direction]
  if not term.job_id or not is_term_buf_valid(term.buf) then
    vim.notify("No active terminal in " .. direction .. " direction", vim.log.levels.WARN)
    return
  end

  vim.fn.jobsend(term.job_id, cmd .. "\n")
end

-- Close terminal
function M.close_terminal(direction)
  local term = M.terminals[direction]

  if is_win_valid(term.win) then
    vim.api.nvim_win_close(term.win, false)
  end

  if is_term_buf_valid(term.buf) then
    vim.api.nvim_buf_delete(term.buf, { force = true })
  end

  term.buf = nil
  term.win = nil
  term.job_id = nil
end

-- Close all terminals
function M.close_all()
  for direction, _ in pairs(M.terminals) do
    M.close_terminal(direction)
  end
end

-- Toggle terminal (create if doesn't exist, focus if exists, close if focused)
function M.toggle_terminal(direction, opts)
  local term = M.terminals[direction]

  -- If window exists and is focused, close it
  if is_win_valid(term.win) and vim.api.nvim_get_current_win() == term.win then
    vim.api.nvim_win_close(term.win, false)
    term.win = nil
    return
  end

  -- If window exists but not focused, focus it
  if is_win_valid(term.win) then
    vim.api.nvim_set_current_win(term.win)
    if M.config.start_in_insert then
      vim.cmd("startinsert")
    end
    return
  end

  -- Otherwise create new terminal
  M.create_terminal(direction, opts)
end

-- Setup terminal configuration and autocmds
function M.setup(user_config)
  -- Merge user config with defaults
  if user_config then
    M.config = vim.tbl_deep_extend("force", M.config, user_config)
  end

  -- Terminal buffer settings
  vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function(event)
      local buf = event.buf

      -- Set local options
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.signcolumn = "no"
      vim.opt_local.foldcolumn = "0"
      vim.opt_local.wrap = false

      -- Store job_id for this buffer
      local job_id = vim.b[buf].terminal_job_id
      for _, term in pairs(M.terminals) do
        if term.buf == buf then
          term.job_id = job_id
          break
        end
      end
    end,
  })

  -- Auto enter insert mode when switching to terminal (if configured)
  if M.config.start_in_insert then
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "term://*",
      callback = function()
        vim.cmd("startinsert")
      end,
    })
  end

  -- Close terminal window when process exits
  vim.api.nvim_create_autocmd("TermClose", {
    pattern = "*",
    callback = function(event)
      local buf = event.buf

      -- Find which terminal this buffer belongs to and clean up
      for direction, term in pairs(M.terminals) do
        if term.buf == buf then
          if is_win_valid(term.win) then
            if M.config.auto_close then
              vim.api.nvim_win_close(term.win, false)
            end
          end
          term.buf = nil
          term.win = nil
          term.job_id = nil
          break
        end
      end

      -- Schedule buffer deletion if auto_close is enabled
      if M.config.auto_close then
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end)
      end
    end,
  })

  -- Prevent accidental closing of terminal with :q
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "term://*",
    callback = function()
      vim.keymap.set("n", "q", function()
        vim.notify("Use :bd or close window with <C-w>c", vim.log.levels.INFO)
      end, { buffer = true, silent = true })
    end,
  })

  -- Exit terminal mode with Esc
  vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })

  -- Alternative exit (double Esc for safety)
  vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { noremap = true, silent = true })

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
