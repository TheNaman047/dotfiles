local Terminal = require("toggleterm.terminal").Terminal

-- Well above the ids <leader>nt hands out; Terminal:new returns an existing
-- terminal by id even when it is hidden, so an overlap would hijack this float.
local PREVIEW_ID = 99

local preview = nil

local function open_preview()
  if vim.fn.executable("glow") == 0 then
    vim.notify("glow not found on PATH", vim.log.levels.ERROR)
    return
  end

  -- The window may already be gone (:q) while glow is still running.
  if preview then
    preview:shutdown()
    preview = nil
  end

  -- Render the buffer, not the file on disk, so unsaved edits show up.
  local tmp = vim.fn.tempname() .. ".md"
  vim.fn.writefile(vim.api.nvim_buf_get_lines(0, 0, -1, false), tmp)

  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.85)

  preview = Terminal:new({
    id = PREVIEW_ID,
    -- glow's "auto" style misdetects the background inside nvim's PTY.
    cmd = string.format(
      "glow -p -s %s -w %d %s",
      vim.o.background == "light" and "light" or "dark",
      math.max(width - 4, 40),
      vim.fn.shellescape(tmp)
    ),
    hidden = true, -- keep it out of <leader>t / ToggleTermToggleAll
    direction = "float",
    close_on_exit = true,
    display_name = "glow",
    float_opts = { width = width, height = height },
    on_exit = function(term)
      vim.fn.delete(tmp)
      -- on_exit is async, so a newer preview may already own the global.
      if preview == term then
        preview = nil
      end
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
