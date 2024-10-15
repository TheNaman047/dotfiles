-- load ollama status functions
local ollama_prompts = require("config.ollama-prompts")

local ollama_url = "https://api-ollama-local.thenaman047.dev"
local ollama_model = "llama3"

local ollama_config = {
  "nomnivore/ollama.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },
  keys = {
    {
      "<leader>oo",
      ":<c-u>lua require('ollama').prompt()<cr>",
      desc = "ollama prompt",
      mode = { "n", "v" },
    },
    {
      "<leader>oa",
      ":<c-u>lua require('ollama').prompt('Ask_About_Code')<cr>",
      desc = "ollama Generate Code",
      mode = { "n", "v" },
    },
  },
  opts = {
    model = ollama_model,
    url = ollama_url,
    prompts = ollama_prompts.prompts,
  },
}

-- Load mistral's codestral model via gen.nvim
local M = {}
M.mistral = {
  host = "codestral.mistral.ai",
  host_url = "https://codestral.mistral.ai/v1/chat/completions",
  model = "codestral-latest",
  api_key = function()
    return os.getenv("MISTRAL_API_KEY")
  end,
}

local gen_nvim_config = {
  "David-Kunz/gen.nvim",
  opts = {
    model = M.mistral.model,
    command = "curl --silent --no-buffer --header 'Authorization: Bearer "
        .. M.mistral.api_key()
        .. "' -X POST "
        .. M.mistral.host_url
        .. " --header 'Content-Type: application/json'"
        .. " -d $body",
    display_mode = "split",
    show_prompt = true,
    show_model = true,
    no_auto_close = false,
    debug = false,
  },
  keys = {
    {
      "<leader>ge",
      ":Gen<CR>",
      desc = "gen prompt",
      mode = { "n", "v" },
    },
  },
}

local cmp_ai = {
  "tzachar/cmp-ai",
  dependencies = "nvim-lua/plenary.nvim",
  config = function()
    local cmp_ai = require("cmp_ai.config")

    cmp_ai:setup({
      max_lines = 1000,
      provider = "Codestral",
      provider_options = {
        model = gen_nvim_model,
      },
      notify = true,
      notify_callback = function(msg)
        print(msg)
        vim.notify(msg)
      end,
      run_on_every_keystroke = false,
    })
  end,
}

local supermaven_config = {
  "supermaven-inc/supermaven-nvim",
  event = "VeryLazy",
  config = function()
    require("supermaven-nvim").setup({})
  end,
}

return {
  ollama_config,
  gen_nvim_config,
  -- cmp_ai,
  -- supermaven_config,
}
