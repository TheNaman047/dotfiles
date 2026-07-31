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

-- Listing is the one place gh and glab genuinely differ: different subcommands and
-- different JSON field names (number/login/isDraft vs iid/username/draft). tuicr itself
-- needs no help here - `tuicr pr N` resolves either forge from the remote.
local FORGES = {
  gh = {
    label = "PRs",
    cmd = { "gh", "pr", "list", "--limit", "100", "--json", "number,title,author,isDraft" },
    item = function(it)
      return { num = it.number, title = it.title, author = (it.author or {}).login, draft = it.isDraft }
    end,
  },
  glab = {
    label = "MRs",
    cmd = { "glab", "mr", "list", "--per-page", "100", "--output", "json" },
    item = function(it)
      return { num = it.iid, title = it.title, author = (it.author or {}).username, draft = it.draft }
    end,
  },
}

local function review_pr()
  local root = require("toggleterm.utils").git_dir()
  local remote = vim.system({ "git", "remote", "get-url", "origin" }, { cwd = root, text = true }):wait()
  local forge = FORGES[(remote.stdout or ""):match("gitlab") and "glab" or "gh"]

  if vim.fn.executable(forge.cmd[1]) == 0 then
    vim.notify(forge.cmd[1] .. " not installed", vim.log.levels.ERROR)
    return
  end

  vim.notify("Fetching open " .. forge.label .. "...")
  vim.system(forge.cmd, { cwd = root, text = true }, vim.schedule_wrap(function(res)
    if res.code ~= 0 then
      -- glab banners its errors across blank lines; collapse so the notification is one useful line
      vim.notify((vim.trim(res.stderr or "list failed"):gsub("%s+", " ")), vim.log.levels.ERROR)
      return
    end
    local ok, raw = pcall(vim.json.decode, res.stdout)
    if not ok or type(raw) ~= "table" or #raw == 0 then
      vim.notify("No open " .. forge.label, vim.log.levels.WARN)
      return
    end
    local items = vim.tbl_map(forge.item, raw)
    vim.ui.select(items, {
      prompt = "Open " .. forge.label,
      format_item = function(i)
        return ("#%s %s%s  (%s)"):format(i.num, i.draft and "[draft] " or "", i.title, i.author or "?")
      end,
    }, function(choice)
      if choice then
        review("pr " .. choice.num)
      end
    end)
  end))
end

local function review_pr_manual()
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
  { "<leader>grp", review_pr,                   desc = "Review PR/MR (pick open)" },
  { "<leader>grP", review_pr_manual,            desc = "Review PR/MR by number/URL" },
  { "<leader>gra", function() review("-A") end, desc = "Review all tracked files" },
}
-- stylua: ignore end
for _, m in ipairs(keymaps) do
  vim.keymap.set("n", m[1], m[2], { desc = m.desc })
end
