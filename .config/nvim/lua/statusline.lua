-- Git branch function
local function git_branch()
  local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
  -- Truncate long branch names
  if #branch > 20 then
    branch = branch:sub(1, 17) .. "..."
  end
  
  return "  " .. branch .. " "
end

-- Set up autocmds to refresh statusline on git-related events
vim.api.nvim_create_augroup("GitBranchUpdate", { clear = true })
vim.api.nvim_create_autocmd({
  "BufEnter",      -- When entering buffers
  "FocusGained",   -- When returning to Neovim
  "DirChanged",    -- When changing directories
  "BufWritePost",  -- After saving files (might trigger git hooks)
}, {
  group = "GitBranchUpdate",
  callback = function()
    vim.cmd("redrawstatus")  -- Force statusline refresh
  end,
})

-- LSP status
local function lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ""
  end
  
  -- Check if any client is ready
  local ready_clients = vim.tbl_filter(function(client)
    return client.initialized
  end, clients)
  
  if #ready_clients == 0 then
    return " 󰒋 LSP... "  -- Loading state
  end
  
  return string.format(" %s ", ready_clients[1].name)
end

_G.git_branch = git_branch
_G.lsp_status = lsp_status

vim.cmd([[
  highlight StatusLineBold gui=bold cterm=bold
]])

-- Function to change statusline based on window focus
local function setup_dynamic_statusline()
  vim.api.nvim_create_autocmd({"WinEnter", "BufEnter"}, {
    callback = function()
    vim.opt_local.statusline = table.concat {
      "%#StatusLineBold#",
      "%#StatusLine#",
      " %f %h%m%r",
      "%{v:lua.git_branch()}",
      "  ",
      "%{v:lua.lsp_status()}",
      "%=",                     -- Right-align everything after this
      "%l:%c  %P ",             -- Line:Column and Percentage
    }
    end
  })
  vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

  vim.api.nvim_create_autocmd({"WinLeave", "BufLeave"}, {
    callback = function()
      vim.opt_local.statusline = "  %f %h%m%r %=  %l:%c   %P "
    end
  })
end
setup_dynamic_statusline()
