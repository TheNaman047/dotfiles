local blink_cmp = {
	"saghen/blink.cmp",
	version = "*",
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
			keymap = {
				preset = "super-tab",
				cmdline = {
					preset = "enter",
				},
			},
			completion = {
				menu = {
					-- nvim-cmp style menu
					draw = {
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "kind_icon", "kind", gap = 1 },
						},
						components = {
							kind_icon = {
								ellipsis = true,
								text = function(ctx)
									return require("lspkind").symbolic(ctx.kind, {
										mode = "symbol",
									})
								end,
							},
						},
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 500,
				},
				list = {
					selection = "manual",
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
				default = { "lsp", "path", "snippets", "buffer", "dadbod" },
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
						score_offset = 85, -- the higher the number, the higher the priority
					},
					buffer = {
						name = "Buffer",
						module = "blink.cmp.sources.buffer",
						min_keyword_length = 2,
						score_offset = 90,
					},
					snippets = {
						name = "snippets",
						enabled = true,
						module = "blink.cmp.sources.snippets",
						score_offset = 80, -- the higher the number, the higher the priority
						opts = {
							friendly_snippets = true,
						},
					},
				},
			},
		})
	end,
}

return {
	blink_cmp,
}
