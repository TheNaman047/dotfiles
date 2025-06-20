local Utils = require("../utils/functions")
-- load ollama status functions
local ollama_prompts = require("config.ollama-prompts")

local avante_config = {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = true,
  version = "*",
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
  config = function()
    -- deps:
    require("img-clip").setup({})
    require("render-markdown").setup({})
    require("avante_lib").load()
    local config = require("avante")
    config.setup({
      provider = "claude",
      cursor_applying_provider = "groq",
      fallback_provider = "groq",
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-20250514",
        temperature = 0,
        max_tokens = 4096,
        disable_tools = true,
        timeout = 120,
      },
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
        jump_result_buffer_on_finish = true,
        enable_cursor_planning_mode = true,
      },
      vendors = {
        groq = {
          __inherited_from = "openai",
          api_key_name = "GROQ_API_KEY",
          endpoint = "https://api.groq.com/openai/v1/",
          model = "llama-3.3-70b-versatile",
          max_completion_tokens = 32768,
          timeout = 60,         -- Added timeout
          disable_tools = true, -- Disable tools for Groq as well
        },
      },
      windows = {
        edit = {
          start_insert = true,
        },
        chat = {
          width = 0.7,
          height = 0.8,
        },
      },
      selector = {
        provider = "telescope",
        provider_opts = {},
      },
      mappings = {
        diff = {
          ours = "<leader>co",
          theirs = "<leader>ct",
          all_theirs = "<leader>ca",
          both = "<leader>cb",
          cursor = "<leader>cc",
          next = "<leader>]x",
          prev = "<leader>[x",
        },
      },
      keymaps = {
        ["<leader>ai"] = { cmd = "AvanteToggle", desc = "Toggle Avante" },
        ["<leader>ac"] = { cmd = "AvanteChat", desc = "Avante Chat" },
        ["<leader>ae"] = { cmd = "AvanteEdit", desc = "Avante Edit" },
        ["<leader>ah"] = { cmd = "AvanteHistory", desc = "Avante History" },
      },
    })
  end,
}

local code_companion_config = {
  "olimorris/codecompanion.nvim",
  opts = {},
  cmd = {
    "CodeCompanionActions",
    "CodeCompanionChat",
    "CodeCompanionHistory"
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "echasnovski/mini.diff",
    "ravitemer/codecompanion-history.nvim",
    { "nvim-lua/plenary.nvim", branch = "master" },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown", "codecompanion" }
    },
    {
      "HakonHarnes/img-clip.nvim",
      opts = {
        filetypes = {
          codecompanion = {
            prompt_for_file_name = false,
            template = "[Image]($FILE_PATH)",
            use_absolute_path = true,
          },
        },
      },
    },
  },
  config = function()
    local diff = require("mini.diff")
    local code_companion = require('codecompanion')
    diff.setup({
      -- Disabled by default
      source = diff.gen_source.none(),
    })
    code_companion.setup({
      strategies = {
        chat = {
          adapter = "anthropic",
          model = "claude-sonnet-4-20250514",
          auto_scroll = false,
          keymaps = {
            send = {
              modes = { n = "<CR>", i = "<C-s>" },
            },
            close = {
              modes = { n = "<C-c>", i = "<C-c>" },
            },
            -- Add further custom keymaps here
          },
        },
        inline = {
          adapter = "anthropic",
        },
      },
      extensions = {
        history = { enabled = true } }
    })
  end,
}

local claude_code_config = {
  "greggh/claude-code.nvim",
  cmd = {
    "ClaudeCode",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("claude-code").setup()
  end
}

return {
  -- avante_config,
  code_companion_config,
  claude_code_config
}
