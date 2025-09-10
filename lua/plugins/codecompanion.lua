return {
	"olimorris/codecompanion.nvim",
	cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionAgent", "CodeCompanionToggle" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		-- The adapter configuration now goes inside the 'http' table
		adapters = {
			http = {
				copilot = function()
					return require("codecompanion.adapters").extend("copilot", {
						name = "copilot",
						schema = {
							model = {
								-- This is the latest high-performance Sonnet model available
								default = "claude-sonnet-4",
							},
						},
					})
				end,
			},
		},
		-- Strategies remain the same, pointing to the 'copilot' adapter
		strategies = {
			chat = {
				adapter = "copilot",
				tools = {
					opts = {
						auto_submit_success = true,
						auto_submit_errors = true,
					},
				},
			},
			inline = {
				adapter = "copilot",
			},
			agent = {
				adapter = "copilot",
			},
		},
		-- Display settings
		display = {
			chat = {
				show_settings = true,
			},
			picker = "fzf_lua",
			action_palette = {
				provider = "fzf_lua",
			},
		},
	},
}
