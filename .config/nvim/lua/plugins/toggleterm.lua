-- Set common opts
local opts = { noremap = true, silent = true }

-- Counts the number of terminals that exist
function CountTerms()
  local buffers = vim.api.nvim_list_bufs()
  local terminal_count = 0
  for _, buf in ipairs(buffers) do
    if vim.bo[buf].buftype == "terminal" then
      terminal_count = terminal_count + 1
    end
  end
  return terminal_count
end

function NewTerm()
  local count = CountTerms() + 1
  vim.cmd("ToggleTerm" .. tostring(count))
end

function CloseTerm()
  if CountTerms() == 0 then
    return
  end
  vim.api.nvim_win_close(vim.api.nvim_get_current_win(), false)
end

vim.api.nvim_set_keymap("n", "<leader>tt", ":call ToggleTerm() <CR>", opts)
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        direction = "horizontal",
      })

      -- Create new Terminals
      vim.api.nvim_set_keymap("n", "<leader>tt", "<cmd>lua NewTerm()<cr>", opts)
      -- Close current Terminal
      vim.api.nvim_set_keymap("n", "<leader>tk", "<cmd>lua CloseTerm()<cr>", opts)

      -- Open Lazygit
      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
        float_opts = {
          border = "curved",
          winblend = 5,
          title_pos = "center",
        },
      })
      function ToggleLazygit()
        lazygit:toggle()
      end

      vim.api.nvim_set_keymap("n", "<leader>l", "<cmd>lua ToggleLazygit()<cr>", opts)
    end,
  },
}
