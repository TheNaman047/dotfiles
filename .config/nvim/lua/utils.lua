local M = {}

function M.copy_file_path()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg("+", path)
  print('file: ', path)
end

return M
