local blink_cmp = {
  "saghen/blink.cmp",
  version = "1.*",
  opts = {},
  opts_extend = { "sources.default" },
  lazy = true,
  dependencies = {
    "onsails/lspkind.nvim",
    {
      "saghen/blink.compat",
      -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
      version = "*",
      -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
      lazy = true,
      -- make sure to set opts so that lazy.nvim calls blink.compat's setup
      opts = {},
    },
    {
      "rafamadriz/friendly-snippets",
      lazy = true,
    },
  },
  config = function()
    local config = require("blink.cmp")
    config.setup({
      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
        },
        completion = { menu = { auto_show = true } },
      },
      keymap = {
        preset = "super-tab",
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 300,
        },
        list = {
          selection = { auto_insert = true, preselect = false },
        },
        trigger = {
          show_in_snippet = false,
        },
      },
      fuzzy = {
        use_frecency = true,
        use_proximity = true,
      },
      signature = { enabled = false, window = { border = "single" } },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = {
          "lsp",
          "path",
          "snippets",
          "buffer",
          "dadbod",
          "avante_commands",
          "avante_mentions",
          "avante_files",
        },
        providers = {
          path = {
            name = "Path",
            module = "blink.cmp.sources.path",
            score_offset = 3,
            -- When typing a path, I would get snippets and text in the
            -- suggestions, I want those to show only if there are no path
            -- suggestions
            fallbacks = { "snippets", "luasnip", "buffer" },
            opts = {
              trailing_slash = false,
              label_trailing_slash = true,
              get_cwd = function(context)
                return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
              end,
              show_hidden_files_by_default = true,
            },
          },
          -- Example on how to configure dadbod found in the main repo
          -- https://github.com/kristijanhusak/vim-dadbod-completion
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
            fallbacks = { "buffer" },
          },
          buffer = {
            name = "Buffer",
            module = "blink.cmp.sources.buffer",
            min_keyword_length = 2,
          },
          snippets = {
            name = "snippets",
            enabled = true,
            module = "blink.cmp.sources.snippets",
            opts = {
              friendly_snippets = true,
            },
          },
          avante_commands = {
            name = "avante_commands",
            module = "blink.compat.source",
            score_offset = 90, -- show at a higher priority than lsp
            opts = {},
          },
          avante_files = {
            name = "avante_files",
            module = "blink.compat.source",
            score_offset = 100, -- show at a higher priority than lsp
            opts = {},
          },
          avante_mentions = {
            name = "avante_mentions",
            module = "blink.compat.source",
            score_offset = 1000, -- show at a higher priority than lsp
            opts = {},
          },
        },
      },
    })
  end,
}

return {
  blink_cmp,
}
