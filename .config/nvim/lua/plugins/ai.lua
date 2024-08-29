-- load ollama status functions
local ollama_prompts = require("config.ollama-prompts")

local ollama_url = "https://api-ollama-local.thenaman047.dev"
local ollama_model = "llama3"
local gen_nvim_model = "codestral-latest"
local gen_nvim_host = "codestral.mistral.ai"
local mistral_curl = function(mistralAPIKey)
	return "curl --silent --no-buffer --header 'Authorization: Bearer "
		.. mistralAPIKey
		.. "' -X POST https://"
		.. gen_nvim_host
		.. "/v1/chat/completions -d $body"
end
local ollama_curl = "curl --silent --no-buffer -X POST https://" .. gen_nvim_host .. "/api/chat -d $body"

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

local gen_nvim_config = {
	"David-Kunz/gen.nvim",
	opts = {
		model = gen_nvim_model,
		host = gen_nvim_host,
		port = "",
		command = function(options)
			local body = { model = options.model, stream = true }
			local mistralAPIKey = os.getenv("MISTRAL_API_KEY")
			if not mistralAPIKey then
				print("Error: MISTRAL_API_KEY environment variable is not set.")
				return nil
			end
			local endpoint = mistral_curl(mistralAPIKey)
			return endpoint
		end,
		display_mode = "split",
		show_prompt = true,
		show_model = true,
		no_auto_close = false,
		debug = true,
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
	config = function()
		require("supermaven-nvim").setup({})
	end,
}

return {
	ollama_config,
	gen_nvim_config,
	-- cmp_ai,
	supermaven_config,
}
