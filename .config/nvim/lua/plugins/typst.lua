vim.pack.add({
  { src = "https://github.com/chomosuke/typst-preview.nvim", version = vim.version.range("1.*") },
})

-- setup() is what fetches/refreshes the tinymist + websocat binaries.
-- Its own :TypstPreview opens a browser; <leader>mt below previews in tmux instead.
require("typst-preview").setup({})

local png = vim.fn.stdpath("cache") .. "/typst-preview.png"
local script = vim.fn.expand("~/.config/tmux/scripts/typst-preview-pane.sh")
local pane ---@type string?

-- Reuse the tinymist that typst-preview downloaded; the name carries an arch suffix.
local function tinymist()
  return vim.fn.glob(vim.fn.stdpath("data") .. "/typst-preview/tinymist-*")
end

-- tinymist rejects any entry outside its project root ("path must be a valid
-- virtual path: Escapes"), so --root is required for absolute paths. Same
-- markers typst-preview's own get_root uses, so both previews agree on root.
local function root(file)
  return os.getenv("TYPST_ROOT") or vim.fs.root(file, { "typst.toml", ".git" }) or vim.fs.dirname(file)
end

-- ponytail: page 1 only. typst's PNG export *rejects* a plain output path for
-- multi-page docs, so --pages 1 is what keeps a single file valid. Multi-page
-- needs a {n} pattern plus paging in the shell script.
local function compile()
  local file = vim.api.nvim_buf_get_name(0)
  vim.system({
    tinymist(), "compile", "--root", root(file), "-f", "png", "--pages", "1", file, png,
  }, {}, function(r)
    -- tinymist panics via SIGABRT, which lands in signal, not code.
    if r.code ~= 0 or (r.signal or 0) ~= 0 then
      vim.schedule(function()
        vim.notify("typst compile failed:\n" .. (r.stderr or ""), vim.log.levels.ERROR)
      end)
    end
  end)
end

-- tmux display-message exits 0 even for a dead pane, so enumerate instead.
local function alive()
  if not pane then return false end
  local out = vim.system({ "tmux", "list-panes", "-a", "-F", "#{pane_id}" }):wait()
  return vim.tbl_contains(vim.split(vim.trim(out.stdout or ""), "\n"), pane)
end

local function toggle()
  if not vim.env.TMUX then
    return vim.notify("Not in tmux; use :TypstPreview", vim.log.levels.WARN)
  end
  if alive() then
    vim.system({ "tmux", "kill-pane", "-t", pane }):wait()
    pane = nil
    return
  end
  compile()
  -- -t our own pane: without it tmux splits the session's *active* window,
  -- which may not be the one nvim is in.
  local out = vim.system({
    "tmux", "split-window", "-h", "-d", "-t", vim.env.TMUX_PANE,
    "-P", "-F", "#{pane_id}", script, png,
  }):wait()
  pane = vim.trim(out.stdout)
end

vim.api.nvim_create_autocmd("BufWritePost", {
  group = require("utils").augroup("typst_preview"),
  pattern = "*.typ",
  callback = function()
    if alive() then compile() end
  end,
})

vim.keymap.set("n", "<leader>mt", toggle, { desc = "Toggle typst preview (tmux pane)" })
