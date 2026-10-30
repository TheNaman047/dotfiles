vim.pack.add({
  "https://github.com/coder/claudecode.nvim",
  "https://github.com/NickvanDyke/opencode.nvim",
})

-- OpenCode config
vim.g.opencode_opts = {}

-- native = plain :terminal split, no snacks dependency
require("claudecode").setup({
  terminal = {
    provider = "native",
    split_side = "right",
    split_width_percentage = 0.4,
    -- Its auto_close calls nvim_win_close unguarded: E444 when the Claude
    -- terminal is the last window (e.g. the daemon restarts on update).
    -- The TermClose autocmd below does the closing instead.
    auto_close = false,
  },
  diff_opts = {
    layout = "vertical",
    open_in_new_tab = false,
  },
})

vim.api.nvim_create_autocmd("TermClose", {
  group = vim.api.nvim_create_augroup("claudecode_term_close", { clear = true }),
  pattern = "term://*",
  callback = function(args)
    -- term://<cwd>//<pid>:<cmd>; match the command, not a cwd under .claude/
    if not args.match:match("//%d+:%S*claude") then return end
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then return end
      for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
        local tab = vim.api.nvim_win_get_tabpage(win)
        if #vim.api.nvim_tabpage_list_wins(tab) > 1 or #vim.api.nvim_list_tabpages() > 1 then
          vim.api.nvim_win_close(win, true)
        else
          vim.api.nvim_win_call(win, function() vim.cmd("enew") end)
        end
      end
      pcall(vim.api.nvim_buf_delete, args.buf, { force = true })
    end)
  end,
})

local function cc(desc) return { noremap = true, silent = true, desc = desc } end

vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", cc("Claude: toggle"))
vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", cc("Claude: focus"))
vim.keymap.set("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", cc("Claude: resume"))
vim.keymap.set("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", cc("Claude: continue"))
-- Agent view lists every project's sessions by default; --cwd scopes it to nvim's cwd
vim.keymap.set("n", "<leader>aa", function()
  vim.cmd("ClaudeCode agents --cwd " .. vim.fn.shellescape(vim.fn.getcwd()))
end, cc("Claude: agent view (cwd only)"))
vim.keymap.set("n", "<leader>am","<cmd>ClaudeCodeSelectModel<cr>", cc("Claude: select model"))

vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", cc("Claude: add current file"))
vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", cc("Claude: send selection"))
-- vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", cc("Claude: accept diff"))
vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", cc("Claude: deny diff"))
vim.keymap.set("n", "<leader>aq", "<cmd>ClaudeCodeCloseAllDiffs<cr>", cc("Claude: close all diffs"))

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("claudecode_tree", { clear = true }),
  pattern = "oil",
  callback = function(args)
    vim.keymap.set({ "n", "v" }, "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>",
      { buffer = args.buf, noremap = true, silent = true, desc = "Claude: add file(s)" })
  end,
})

-- OpenCode
vim.keymap.set({ "n", "x" }, "<leader>ea", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
vim.keymap.set({ "n", "x" }, "<leader>ex", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
vim.keymap.set({ "n", "x" }, "<leader>er",  function() return require("opencode").operator("@this ") end,        { desc = "Add range to opencode", expr = true })
vim.keymap.set("n",          "<leader>ef", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })
