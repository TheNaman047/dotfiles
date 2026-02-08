vim.pack.add({
  "https://github.com/echasnovski/mini.pick",
  "https://github.com/echasnovski/mini.pairs",
  "https://github.com/echasnovski/mini.snippets",
})

require "mini.pick".setup({ options = { use_cache = true } })
require "mini.pairs".setup()

local gen_loader = require('mini.snippets').gen_loader
require('mini.snippets').setup({
  mappings = {
    expand = '<C-e>',
    jump_next = '<C-j>',
    jump_prev = '<C-k>',
    stop = '<C-c>',
  },
  snippets = {
    gen_loader.from_file('~/.config/nvim/snippets/global.json'),
    -- Load snippets based on current language by reading files from
    -- "snippets/" subdirectories from 'runtimepath' directories.
    gen_loader.from_lang(),
  },
})

local M = {}
-- Custom functions
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

function M.pick_with_hidden()
  MiniPick.builtin.cli({
    -- find files and directories with fd
    command = { 'fd', '--hidden', '--type', 'f', '--exclude', '.git' },
  }, {
    source = {
      name = 'Files',
      show = function(buf_id, items, query)
        MiniPick.default_show(buf_id, items, query, { show_icons = true })
      end,
      choose = vim.schedule_wrap(MiniPick.default_choose),
    },
  })
end

-- Keymaps
local buffer_mappings = { wipeout = { char = '<C-d>', func = M.wipeout_cur_buf } }
local local_opts = { include_current = false }
vim.keymap.set("n", "<leader>p", M.pick_with_hidden, opts)
vim.keymap.set("n", "<leader>gf", ":Pick grep<CR>", opts)
vim.keymap.set("n", "<leader>gb", function()
  MiniPick.builtin.buffers(local_opts, { mappings = buffer_mappings })
end, opts)
vim.keymap.set("n", "<leader>l", ":Pick grep_live<CR>", opts)
vim.keymap.set("n", "<leader>r", ":Pick resume<CR>", opts)
vim.keymap.set("n", "<leader>h", ":Pick help<CR>", opts)
