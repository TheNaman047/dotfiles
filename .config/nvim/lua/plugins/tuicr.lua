-- tuicr (https://tuicr.dev) is a standalone binary, not a plugin - just launch it in a
-- float. Forge is auto-detected from the remote, so `pr` covers gh PRs and glab MRs alike.
local Terminal = require("toggleterm.terminal").Terminal

local function review(args)
  if vim.fn.executable("tuicr") == 0 then
    vim.notify("tuicr not installed: brew install agavra/tap/tuicr", vim.log.levels.ERROR)
    return
  end
  Terminal:new({
    cmd = "tuicr " .. args,
    direction = "float",
    dir = "git_dir",
    close_on_exit = true,
    float_opts = {
      width = function()
        return math.floor(vim.o.columns * 0.95)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.95)
      end,
    },
    -- tuicr can't write files, but a review often ends in edits made elsewhere
    on_close = function() vim.cmd("checktime") end,
  }):toggle()
end

local function review_file()
  local path = vim.fn.expand("%:p")
  if path == "" or vim.bo.buftype ~= "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end
  review("-w -p " .. vim.fn.shellescape(path))
end

local function review_pr()
  vim.ui.input({ prompt = "PR/MR number, owner/repo#N, or URL: " }, function(input)
    if input and vim.trim(input) ~= "" then
      review("pr " .. vim.fn.shellescape(vim.trim(input)))
    end
  end)
end

-- stylua: ignore start
local keymaps = {
  { "<leader>grr", function() review("-w") end, desc = "Review working tree" },
  { "<leader>grf", review_file,                 desc = "Review current file" },
  { "<leader>grc", function() review("") end,   desc = "Review commits (selector)" },
  { "<leader>grp", review_pr,                   desc = "Review PR/MR" },
  { "<leader>gra", function() review("-A") end, desc = "Review all tracked files" },
}
-- stylua: ignore end
for _, m in ipairs(keymaps) do
  vim.keymap.set("n", m[1], m[2], { desc = m.desc })
end
