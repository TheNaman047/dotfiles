-- after/plugin/herdr_nav.lua owns <C-hjkl> (vim splits -> herdr panes -> tmux).
-- Must be set before the plugin loads, or it installs its own mappings.
vim.g.tmux_navigator_no_mappings = 1

vim.pack.add({
  "https://github.com/christoomey/vim-tmux-navigator",
  "https://github.com/ibhagwan/smartyank.nvim",
  "https://github.com/smithbm2316/centerpad.nvim",
  "https://github.com/adriankarlen/plugin-view.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/vuki656/package-info.nvim",
  "https://github.com/tpope/vim-sleuth",
})

require "plugin-view".setup({})
require "package-info".setup({})
require "smartyank".setup()

-- plugin-view calls :sub() straight on spec.version, so a vim.version.range()
-- pin (a VersionRange table, e.g. typst-preview) blows up its window. Hand it
-- strings instead. Wrapping the module table survives plugin updates.
local pv_utils = require "plugin-view.utils"
local pv_populate = pv_utils.populate_buf

-- Rebuild the "1.*" / "1.2.*" wildcard forms a range was written as: tostring()
-- spells them out as "1.0.0 - 2.0.0", well past the 10-cell version column.
local function version_string(v)
  local from, to = v.from, v.to
  if from and to and from.patch == 0 and to.patch == 0 then
    if from.minor == 0 and to.minor == 0 and to.major == from.major + 1 then
      return from.major .. ".*"
    end
    if to.major == from.major and to.minor == from.minor + 1 then
      return from.major .. "." .. from.minor .. ".*"
    end
  end
  return (tostring(v):gsub("%s+", ""))
end

pv_utils.populate_buf = function(buf, plugins)
  return pv_populate(buf, vim.tbl_map(function(plugin)
    local version = plugin.spec.version
    if version == nil or type(version) == "string" then
      return plugin
    end
    local spec = vim.tbl_extend("force", plugin.spec, { version = version_string(version) })
    return vim.tbl_extend("force", plugin, { spec = spec })
  end, plugins))
end

local opts = { noremap = true, silent = true }

-- Plugin View keymaps
vim.keymap.set("n", "<leader>v", require("plugin-view").open, opts)

-- Centerpad keymap
vim.keymap.set('n', '<leader>z', '<cmd>Centerpad<cr>', opts)

-- Package Info keymap
vim.keymap.set('n', '<leader>ns', '<cmd>lua require("package-info").show()<cr>', opts)
vim.keymap.set('n', '<leader>np', '<cmd>lua require("package-info").change_version()<cr>', opts)
