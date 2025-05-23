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

local avante_config = {
	"yetone/avante.nvim",
	event = "VeryLazy",
	lazy = true,
  version = "v0.0.23",
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
					timeout = 60, -- Added timeout
				},
			},
			windows = {
				edit = {
					start_insert = true, -- Start insert mode when opening the edit window
				},
				chat = {
					width = 0.7, -- Added width configuration
					height = 0.8, -- Added height configuration
				},
			},
			selector = {
				---@alias avante.SelectorProvider "native" | "fzf_lua" | "mini_pick" | "snacks" | "telescope" | fun(selector: avante.ui.Selector): nil
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
				suggestion = {
					accept = "<M-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
				jump = {
					next = "]]",
					prev = "[[",
				},
				submit = {
					normal = "<CR>",
					insert = "<C-s>",
				},
				sidebar = {
					apply_all = "A",
					apply_cursor = "a",
					switch_windows = "<Tab>",
					reverse_switch_windows = "<S-Tab>",
				},
			},
			hints = {
				enabled = true,
				position = "inline", -- Added position setting
			},
			-- Added keymaps section for custom commands
			keymaps = {
				["<leader>ai"] = { cmd = "AvanteToggle", desc = "Toggle Avante" },
				["<leader>ac"] = { cmd = "AvanteChat", desc = "Avante Chat" },
				["<leader>ae"] = { cmd = "AvanteEdit", desc = "Avante Edit" },
				["<leader>ah"] = { cmd = "AvanteHistory", desc = "Avante History" },
			},
		})
	end,
}

return {
	ollama_config,
	gen_nvim_config,
	-- cmp_ai,
	-- supermaven_config,
	avante_config,
}
