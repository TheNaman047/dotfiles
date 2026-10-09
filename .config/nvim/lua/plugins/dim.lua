-- Fades inactive windows. Lives outside plugins.theme so it applies to every theme;
-- themes' own dimInactive/NormalNC is useless here since they're all transparent.
vim.pack.add({ "https://github.com/tadaa/vimade" })

-- Transparent themes leave Normal bg NONE, so vimade would fade toward pure black/white.
-- Fade toward the terminal's real background instead, read via OSC 11.
local term_bg

vim.api.nvim_create_autocmd("TermResponse", {
  group = require("utils").augroup("vimade_basebg"),
  callback = function(ev)
    local r, g, b = (ev.data.sequence or ""):match("^\027%]11;rgb:(%x+)/(%x+)/(%x+)")
    if not r then
      return
    end
    term_bg = ("#%s%s%s"):format(r:sub(1, 2), g:sub(1, 2), b:sub(1, 2))
    vim.schedule(function()
      vim.cmd("VimadeRedraw")
    end)
    return true
  end,
})
if #vim.api.nvim_list_uis() > 0 then
  io.stdout:write("\027]11;?\007")
end

require("vimade").setup({
  recipe = { "default", { animate = false } },
  ncmode = "windows", -- same buffer in two splits still dims the inactive one
  fadelevel = 0.5,
  basebg = function()
    return term_bg
  end,
})
