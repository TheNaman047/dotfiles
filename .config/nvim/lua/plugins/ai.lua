return {
	--[[ {
		"David-Kunz/gen.nvim",
		opts = {
			model = "codellama:7b-code", -- The default model to use.
			host = "api-ollama-local.thenaman047.dev", -- The host running the Ollama service.
			port = "", -- The port on which the Ollama service is listening.
			quit_map = "q", -- set keymap for close the response window
			retry_map = "<c-r>", -- set keymap to re-send the current prompt
			-- Function to initialize Ollama
			command = function(options)
				local body = { model = options.model, stream = true }
				local command = "curl --silent --no-buffer -X POST http://" .. options.host
				if options.port ~= nil and options.port ~= "" then
					command = command .. ":" .. options.port
				end

				command = command .. "/api/chat -d $body"
        require('notify')(command)
				return command
			end,
			-- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
			-- This can also be a command string.
			-- The executed command must return a JSON object with { response, context }
			-- (context property is optional).
			-- list_models = '<omitted lua function>', -- Retrieves a list of model names
			display_mode = "split", -- The display mode. Can be "float" or "split".
			show_prompt = true, -- Shows the prompt submitted to Ollama.
			show_model = true, -- Displays which model you are using at the beginning of your chat session.
			no_auto_close = false, -- Never closes the window automatically.
			debug = false, -- Prints errors and the command which is run.
		},
		config = function()
			vim.keymap.set({ "n", "v" }, "<leader>o", ":Gen<CR>")
		end,
	}, ]]
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
				"<leader>og",
				":<c-u>lua require('ollama').prompt('Generate_Code')<cr>",
				desc = "ollama Generate Code",
				mode = { "n", "v" },
			},
		},

		---@type Ollama.Config
		opts = {
			-- your configuration overrides
			model = "codellama:7b-code",
			url = "https://api-ollama-local.thenaman047.dev",
			-- View the actual default prompts in ./lua/ollama/prompts.lua
			prompts = {
				Sample_Prompt = {
					prompt = "This is a sample prompt that receives $input and $sel(ection), among others.",
					input_label = "> ",
					model = "mistral",
					action = "display",
				},
			},
		},
	},
}
