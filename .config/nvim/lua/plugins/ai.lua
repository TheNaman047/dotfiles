-- load ollama status functions
local ollama_prompts = require("config.ollama-prompts")

return {
	{
		"nomnivore/ollama.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},

		-- All the user commands added by the plugin
		cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },

		keys = {
			-- Sample keybind for prompt menu. Note that the <c-u> is important for selections to work properly.
			{
				"<leader>oo",
				":<c-u>lua require('ollama').prompt()<cr>",
				desc = "ollama prompt",
				mode = { "n", "v" },
			},

			-- Sample keybind for direct prompting. Note that the <c-u> is important for selections to work properly.
			{
				"<leader>oa",
				":<c-u>lua require('ollama').prompt('Ask_About_Code')<cr>",
				desc = "ollama Generate Code",
				mode = { "n", "v" },
			},
		},

		---@type Ollama.Config
		opts = {
			-- your configuration overrides
			model = "llama3",
			url = "https://api-ollama-local.thenaman047.dev",
			-- View the actual default prompts in ./lua/ollama/prompts.lua
			prompts = ollama_prompts.prompts,
		},
	},
	{
		"David-Kunz/gen.nvim",
		opts = {
			model = "codestral-latest", -- The default model to use.
			-- host = "api-ollama-local.thenaman047.dev", -- The host running the Ollama service.
			host = "codestral.mistral.ai", -- The host running the Ollama service.
			port = "", -- The port on which the Ollama service is listening.
			command = function(options)
				local body = { model = options.model, stream = true }
				-- local endpoint = "curl --silent --no-buffer -X POST https://" .. options.host .. "/api/chat -d $body"
				local endpoint = "curl --silent --no-buffer --header 'Authorization: Bearer wEhqpNThFsssFUOjtVLqTpvvpPHGvce4' -X POST https://"
					.. options.host
					.. "/v1/chat/completions -d $body"
				return endpoint
			end,
			-- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
			-- This can also be a command string.
			-- The executed command must return a JSON object with { response, context }
			-- (context property is optional).
			-- list_models = '<omitted lua function>', -- Retrieves a list of model names
			display_mode = "split", -- The display mode. Can be "float" or "split" or "horizontal-split".
			show_prompt = true, -- Shows the prompt submitted to Ollama.
			show_model = true, -- Displays which model you are using at the beginning of your chat session.
			no_auto_close = false, -- Never closes the window automatically.
			debug = true, -- Prints errors and the command which is run.
		},
		keys = {
			{
				"<leader>ge",
				":Gen<CR>",
				desc = "gen prompt",
				mode = { "n", "v" },
			},
		},
	},
}
