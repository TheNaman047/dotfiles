local M = {}

-- Mini pick functions
-- Remove the buffer and move to the next file
-- Mini pick functions - simplified approach
function M.wipeout_cur_buf()
  local matches = MiniPick.get_picker_matches()
  local current_match = matches.current
  local all_matches = matches.all

  -- Find current index
  local current_index = 1
  for i, match in ipairs(all_matches) do
    if match.bufnr == current_match.bufnr then
      current_index = i
      break
    end
  end

  -- Delete the buffer
  vim.api.nvim_buf_delete(current_match.bufnr, {})

  -- Filter out invalid buffers and update
  local filtered_items = vim.tbl_filter(function(item)
    return vim.api.nvim_buf_is_valid(item.bufnr)
  end, MiniPick.get_picker_items())

  MiniPick.set_picker_items(filtered_items)

  -- Use vim.schedule to navigate after update
  vim.schedule(function()
    local new_matches = MiniPick.get_picker_matches()
    if #new_matches.all > 0 then
      local target_index = math.min(current_index, #new_matches.all)
      -- Move to target position using built-in navigation
      for _ = 1, target_index - 1 do
        vim.api.nvim_input('<C-n>')
      end
    end
  end)
end

return M
