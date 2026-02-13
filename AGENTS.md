# AGENTS.md - Developer Guidelines for Neovim Dotfiles

This repository contains personal Neovim configuration written in Lua. This guide helps AI agents understand the codebase structure, style conventions, and development workflows.

## Repository Overview

- **Type:** Neovim editor configuration (dotfiles)
- **Language:** Lua with vim Lua API
- **Main Config:** `.config/nvim/init.lua`
- **Package Manager:** vim.pack (built-in plugin manager)
- **Active Language Servers:** ts_go_ls, lua_ls, vtsls, vue_ls, jsonls, basedpyright, ruff

This is a configuration repository, not a library or application. Changes are validated through LSP integration and manual testing in Neovim.

## Development Commands

### Reload Configuration

```bash
# From inside Neovim
:source ~/.config/nvim/init.lua      # Reload entire config
:source %                             # Reload current file
<leader>o                             # Mapped to update and source current file
```

### LSP Validation

```bash
# Language servers are configured in lsp/*.lua and auto-started
# No explicit test commands - validation happens via LSP diagnostics
# Check LSP status in Neovim: <leader>i (CodeCompanionChat) or vim.lsp.buf.* commands
```

### Testing Changes

1. Edit a file in `.config/nvim/`
2. Reload with `:source %` or `:source ~/.config/nvim/init.lua`
3. Verify in Neovim (check keymaps, plugins load, no errors)
4. Test specific features (e.g., terminal with `<leader>t`, database UI with `<leader>d`)

### No Build/Lint Commands

This is a configuration repo. There are no compilation steps or external linters. LSP servers provide type checking and diagnostics for code files edited in Neovim.

## Code Style Guidelines

### Imports & Module Structure

**All Lua modules use the standard pattern:**

```lua
local M = {}

-- Public functions/config
function M.setup(user_config)
  -- Setup logic
end

function M.some_function()
  -- Implementation
end

return M
```

**Importing modules:**

```lua
local utils = require('utils')
local terminal = require("term")
local blink_cmp = require('blink.cmp')
```

Use relative paths from `lua/` directory. Always assign to local variable.

### Formatting & Indentation

- **Indentation:** 2 spaces (configured: `vim.o.tabstop = 2`, `vim.o.shiftwidth = 2`)
- **Expand tabs:** true (no literal tabs)
- **Line length:** 100 characters max (`vim.o.colorcolumn = "100"`)
- **Line endings:** LF (Unix)

**Example:**

```lua
require('blink.cmp').setup({
  keymap = { preset = 'super-tab' },
  snippets = { preset = 'mini_snippets' },
  completion = {
    accept = {
      auto_brackets = { enabled = true },
    },
  },
})
```

### Naming Conventions

- **Module names:** lowercase with hyphens (`term.lua`, `mini-pick.lua`, `db.lua`)
- **Functions:** snake_case (`copy_file_path`, `create_terminal`, `git_branch`)
- **Local variables:** snake_case (`local opts = ...`, `local terminal = ...`)
- **Constants:** UPPER_SNAKE_CASE (rarely used; config tables are normal case)
- **Vim global options:** `vim.o.` or `vim.opt.` (e.g., `vim.o.expandtab`)
- **Keymaps:** use descriptive names in opts: `{ noremap = true, silent = true, desc = "..." }`

### Error Handling

- **Assertions:** Use `assert()` for expected conditions:
  ```lua
  local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
  ```

- **Notifications:** Use `vim.notify()` for user-facing errors:
  ```lua
  vim.notify("Invalid terminal direction: " .. direction, vim.log.levels.ERROR)
  vim.notify("No active terminal in " .. direction, vim.log.levels.WARN)
  ```

- **Validation:** Check buffer/window validity before operating:
  ```lua
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  ```

### Type & LSP Configuration

LSP configs are in `lsp/` directory. Each returns a table with server options:

```lua
return {
  cmd = { 'server-command', '--stdio' },
  filetypes = { 'lang1', 'lang2' },
  root_markers = { 'package.json', '.git' },
  settings = { /* server-specific settings */ },
  on_attach = function(client, bufnr)
    -- Custom buffer-local setup
  end,
}
```

LSP servers are enabled in `init.lua`:
```lua
vim.lsp.enable({ "ts_go_ls", "lua_ls", "vtsls", "vue_ls", "jsonls", "basedpyright", "ruff" })
```

### Comments

- Use `--` for single-line comments
- Avoid over-commenting obvious code
- Document non-obvious logic or configuration rationale:
  ```lua
  -- Set Dadbod UI location outside repo to avoid tracking passwords
  vim.g.db_ui_save_location = "~/Applications/dadbod-ui/"
  ```

## File Organization

```
.config/nvim/
├── init.lua                 # Main entry point (277 lines)
├── .luarc.json             # Lua LSP configuration
├── nvim-pack-lock.json     # Plugin lock file
├── lsp/                    # Language server configs
│   ├── basedpyright.lua
│   ├── jsonls.lua
│   ├── lua_ls.lua
│   ├── ruff.lua
│   ├── ts_go_ls.lua
│   ├── ts_ls.lua
│   ├── vtsls.lua
│   └── vue_ls.lua
├── lua/                    # Lua modules
│   ├── db.lua              # Database UI setup
│   ├── mini-pick.lua       # File picker integration (290 lines)
│   ├── statusline.lua      # Custom statusline
│   ├── term.lua            # Terminal management (290 lines)
│   └── utils.lua           # Utility functions
└── snippets/               # LSP snippets
    ├── global.json
    ├── javascript.json
    └── typescript.json
```

**Guidelines:**
- Keep `init.lua` as the plugin/setup orchestration layer
- Complex logic (>50 lines) belongs in `lua/` modules
- LSP-specific code goes in `lsp/` directory
- One LSP per file in `lsp/`

## Common Patterns

### Plugin Setup

Plugins are declared with `vim.pack.add()`:

```lua
vim.pack.add({
  { src = "https://github.com/author/plugin.nvim" },
  { src = "https://github.com/author/another.nvim", version = "v1.0.0" },
})

-- Then configure after loading
require('plugin').setup({ option = true })
```

### Keymaps

```lua
local opts = { noremap = true, silent = true }

-- Normal mode
vim.keymap.set("n", "<leader>fd", vim.lsp.buf.format, opts)

-- Multiple modes
vim.keymap.set({ "n", "x" }, "<leader>er", function() ... end, { desc = "..." })

-- Terminal mode (use Ctrl + backslash)
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { noremap = true })
```

### Autocommands

```lua
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my_group', { clear = true }),
  callback = function(args)
    -- Handle event
  end,
})
```

### Module with Setup Function

```lua
local M = {}

M.config = {
  size = 0.3,
  position = "bottom",
}

function M.setup(user_config)
  if user_config then
    M.config = vim.tbl_deep_extend("force", M.config, user_config)
  end
end

return M
```

## Commit Conventions

Follow conventional commits (observed in git history):

```
feat: add new feature (new functionality)
fix: fix bug (bug fix)
chore: maintenance task (no code change)
refactor: restructure code (no behavior change)
docs: documentation changes
```

Example: `feat: add package-info.nvim plugin with keymaps`

## Tools & Language Servers

| Language | Server | Config |
|----------|--------|--------|
| Lua | lua_ls | `lsp/lua_ls.lua` |
| TypeScript/JavaScript | vtsls | `lsp/vtsls.lua` |
| TypeScript/Go (alt) | ts_go_ls | `lsp/ts_go_ls.lua` |
| Vue | vue_ls | `lsp/vue_ls.lua` |
| JSON | jsonls | `lsp/jsonls.lua` |
| Python | basedpyright | `lsp/basedpyright.lua` |
| Python (linting) | ruff | `lsp/ruff.lua` |

All servers use the native `vim.lsp.enable()` API. No external manager required.

## Tips for Agents

1. **Test changes immediately:** Reload config with `:source %` and verify behavior in Neovim
2. **Check LSP diagnostics:** Use LSP to validate Lua syntax and undefined variables
3. **Use existing patterns:** Follow module structure and configuration style for consistency
4. **Document non-obvious logic:** Comment why, not what
5. **Keep init.lua focused:** It orchestrates plugins; complex logic belongs in `lua/` modules
6. **Respect indentation:** Always use 2 spaces; the config enforces this
7. **Test keymaps:** Verify new keymaps don't conflict with existing ones
