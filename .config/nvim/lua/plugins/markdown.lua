local Terminal = require("toggleterm.terminal").Terminal

local preview = nil

local function open_preview()
  if vim.fn.executable("glow") == 0 then
    vim.notify("glow not found on PATH", vim.log.levels.ERROR)
    return
  end

  -- Render the buffer, not the file on disk, so unsaved edits show up.
  local tmp = vim.fn.tempname() .. ".md"
  vim.fn.writefile(vim.api.nvim_buf_get_lines(0, 0, -1, false), tmp)

  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.85)

  preview = Terminal:new({
    -- glow's "auto" style misdetects the background inside nvim's PTY.
    cmd = string.format(
      "glow -p -s %s -w %d %s",
      vim.o.background == "light" and "light" or "dark",
      width - 4,
      vim.fn.shellescape(tmp)
    ),
    hidden = true, -- keep it out of <leader>t / ToggleTermToggleAll
    direction = "float",
    close_on_exit = true,
    display_name = "glow",
    float_opts = { width = width, height = height },
    on_exit = function()
      vim.fn.delete(tmp)
      preview = nil
    end,
  })
  preview:open()
end

local function toggle_preview()
  if preview and preview:is_open() then
    preview:shutdown()
    preview = nil
  else
    open_preview()
  end
end

vim.keymap.set("n", "<leader>mv", toggle_preview, { desc = "Toggle markdown preview (glow)" })
