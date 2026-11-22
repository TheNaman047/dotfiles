vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/pwntester/octo.nvim",
})

require("octo").setup({
  picker = "snacks",
  enable_builtin = true,
})

-- stylua: ignore start
local keymaps = {
  { "<leader>gpr", "<cmd>Octo pr list<cr>",      desc = "List PRs" },
  { "<leader>gps", "<cmd>Octo pr search<cr>",    desc = "Search PRs" },
  -- bare `Octo review` = start_or_resume; `review start` hard-fails if a pending review exists
  { "<leader>gpR", "<cmd>Octo review<cr>",       desc = "Start/resume PR review" },
  { "<leader>gir", "<cmd>Octo issue list<cr>",   desc = "List issues" },
}
-- stylua: ignore end
for _, m in ipairs(keymaps) do
  vim.keymap.set("n", m[1], m[2], { desc = m.desc })
end

-- `Octo pr list` re-runs a paginated GraphQL query on every open. Serve the last
-- response instantly, refresh it behind the picker, and keep it warm on a timer.
local pr_cache = { entries = {}, inflight = {}, ttl = 15 * 60, interval = 3 * 60 * 1000, min_gap = 60, fetches = 0 }
_G.OctoPrCache = pr_cache

local gh = require("octo.gh")
local queries = require("octo.gh.queries")
local utils = require("octo.utils")
local graphql = gh.api.graphql

local function fetch(key, call, cb)
  if pr_cache.inflight[key] and not cb then
    return
  end
  pr_cache.inflight[key] = true
  pr_cache.fetches = pr_cache.fetches + 1
  local opts = vim.deepcopy(call)
  opts.opts = {
    cb = function(output, stderr, status)
      pr_cache.inflight[key] = nil
      if utils.is_blank(stderr) and not utils.is_blank(output) then
        pr_cache.entries[key] = { output = output, time = os.time(), call = call }
      end
      if cb then
        cb(output, stderr, status)
      end
    end,
  }
  graphql(opts)
end

gh.api.graphql = function(opts)
  local run_opts = opts and opts.opts or {}
  if not opts or opts.query ~= queries.pull_requests or run_opts.mode == "sync" or not run_opts.cb then
    return graphql(opts)
  end
  -- key before calling through: create_graphql_opts mutates opts
  local key = vim.inspect(opts.F)
  local call = vim.deepcopy(opts)
  call.opts = nil
  local hit = pr_cache.entries[key]
  if hit and os.time() - hit.time < pr_cache.ttl then
    vim.schedule(function()
      run_opts.cb(hit.output, "", 0)
    end)
    fetch(key, call)
  else
    fetch(key, call, run_opts.cb)
  end
end

-- the first gh call otherwise blocks on a sync `gh auth status` to resolve the viewer
local function seed_viewer(done)
  if vim.g.octo_viewer then
    return done()
  end
  vim.system({ "gh", "auth", "status", "--hostname", utils.get_remote_host() }, { text = true }, function(r)
    local out = (r.stdout or "") .. (r.stderr or "")
    local login = out:match("Logged in to [^%s]+ as ([^%s]+)") or out:match("Logged in to [^%s]+ account ([^%s]+)")
    vim.schedule(function()
      if login then
        vim.g.octo_viewer = login
        done()
      end
    end)
  end)
end

function pr_cache.prefetch(force)
  if not force and #vim.api.nvim_list_uis() == 0 then
    return
  end
  local ok, repo = pcall(utils.get_remote_name)
  if not ok or utils.is_blank(repo) then
    return
  end
  local owner, name = utils.split_repo(repo)
  local default = {
    query = queries.pull_requests,
    F = { owner = owner, name = name, states = { "OPEN" }, order_by = require("octo.config").values.pull_requests.order_by },
    paginate = true,
    jq = ".",
  }
  local calls = { [vim.inspect(default.F)] = default }
  for key, entry in pairs(pr_cache.entries) do
    if entry.call.F.owner == owner and entry.call.F.name == name then
      calls[key] = entry.call
    end
  end
  seed_viewer(function()
    for key, call in pairs(calls) do
      local entry = pr_cache.entries[key]
      if force or not entry or os.time() - entry.time >= pr_cache.min_gap then
        fetch(key, call)
      end
    end
  end)
end

vim.uv.new_timer():start(3000, pr_cache.interval, vim.schedule_wrap(function()
  pr_cache.prefetch()
end))
vim.api.nvim_create_autocmd({ "FocusGained", "DirChanged" }, {
  group = vim.api.nvim_create_augroup("octo_pr_cache", { clear = true }),
  callback = function()
    pr_cache.prefetch()
  end,
})
