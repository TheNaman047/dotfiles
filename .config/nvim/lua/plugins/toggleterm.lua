local Utils = require("../utils/functions")

-- Counts the number of terminals that exist
function CountTerms()
	local buffers = vim.api.nvim_list_bufs()
	local terminal_count = 0
	for _, buf in ipairs(buffers) do
		if vim.bo[buf].buftype == "terminal" then
			terminal_count = terminal_count + 1
		end
	end
	return terminal_count
end

function NewTerm()
	local count = CountTerms() + 1
	vim.cmd("ToggleTerm" .. tostring(count))
end

function CloseTerm()
	if CountTerms() == 0 then
		return
	end
	vim.api.nvim_win_close(vim.api.nvim_get_current_win(), false)
end

return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		event = "VeryLazy",
		config = function()
			local config = require("toggleterm")
			config.setup({})

			-- Create new Terminals
			vim.api.nvim_set_keymap("n", "<leader>tn", "<cmd>lua NewTerm()<cr>", Utils.opts)
			-- Close current Terminal
			vim.api.nvim_set_keymap("n", "<leader>tk", "<cmd>lua CloseTerm()<cr>", Utils.opts)
			-- Toggle current Terminal Visibility
			vim.api.nvim_set_keymap("n", "<leader>tt", ":ToggleTerm<cr>", Utils.opts)

			-- Open Lazygit
			local Terminal = require("toggleterm.terminal").Terminal
			local lazygit = Terminal:new({
				cmd = "lazygit",
				hidden = true,
				direction = "float",
				float_opts = {
					border = "curved",
					winblend = 5,
					title_pos = "center",
				},
			})
			function ToggleLazygit()
				lazygit:toggle()
			end

			vim.api.nvim_set_keymap("n", "<leader>l", "<cmd>lua ToggleLazygit()<cr>", Utils.opts)
		end,
	},
}
