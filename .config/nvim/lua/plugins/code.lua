return {
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
		event = "VeryLazy",
	},
	{
    "windwp/nvim-autopairs",
    event = "InsertEnter",
		opts = {
			disable_filetype = { "TelescopePrompt", "spectre_panel" },
		},
		config = function()
			-- setup nvim-autopairs
			require("nvim-autopairs").setup()
			-- insert `(` after select function or method item
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
}
