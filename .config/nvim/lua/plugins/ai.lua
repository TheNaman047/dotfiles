-- load ollama status functions
local ollama_prompts = require("configs.ollama-prompts")

return {
	{
		"nomnivore/ollama.nvim",
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
			url = "http://localhost:11434",
			-- View the actual default prompts in ./lua/ollama/prompts.lua
			prompts = ollama_prompts.prompts,
		},
	},
}
