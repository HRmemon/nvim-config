return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPost", "BufNewFile", "BufWritePost" },
	build = ":TSUpdate",
	dependencies = {
		-- This is the textobjects extension
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		-- The main treesitter configuration goes here
		require("nvim-treesitter.configs").setup({
			-- Add your list of parsers here
			ensure_installed = { "lua", "vim", "python", "javascript", "typescript", "rust" },

			sync_install = false,
			auto_install = true,

			highlight = {
				enable = true,
			},
			indent = {
				enable = true,
			},

			-- THE TEXTOBJECTS CONFIGURATION GOES *INSIDE* THE MAIN SETUP
			textobjects = {
				select = {
					enable = true,
					lookahead = true, -- Automatically jump forward to textobj
					keymaps = {
						-- You can use the capture groups defined in textobjects.scm
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
						-- You can also add things like loops and conditionals
						["al"] = "@loop.outer",
						["il"] = "@loop.inner",
						["ai"] = "@conditional.outer",
						["ii"] = "@conditional.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true, -- whether to set jumps in the jumplist
					goto_next_start = {
						["]f"] = "@function.outer",
						["]c"] = "@class.outer",
					},
					goto_next_end = {
						["]F"] = "@function.outer",
						["]C"] = "@class.outer",
					},
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[c"] = "@class.outer",
					},
					goto_previous_end = {
						["[F"] = "@function.outer",
						["[C"] = "@class.outer",
					},
				},
			},
		})
	end,
}
