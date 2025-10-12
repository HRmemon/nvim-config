return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- latest release
	event = { "BufReadPre" },
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		legacy_commands = false, -- 🚀 future-proof, no more warnings

		workspaces = {
			{
				name = "main",
				path = "~/notes",
			},
		},

		daily_notes = {
			folder = "GOALS/daily",
			template = "GOALS/templates/daily.md",
		},

		templates = {
			folder = "GOALS/templates",
		},

		--- Add your keymaps here 👇
		callbacks = {
			enter_note = function(_, note)
				-- Bail out if note is nil
				if not note or not note.bufnr then
					return
				end

				local map = function(lhs, rhs, desc)
					vim.keymap.set("n", lhs, rhs, { buffer = note.bufnr, desc = desc })
				end

				map("<leader>od", "<cmd>Obsidian today<cr>", "Open daily note")
				map("gf", "<cmd>Obsidian follow_link<cr>", "Follow Obsidian link")
			end,
		},
		-- ui = {
		-- 	checkboxes = {
		-- 		[" "] = { char = "󰄱", hl_group = "obsidiantodo" },
		-- 		["x"] = { char = "", hl_group = "obsidiandone" },
		-- 	},
		-- },
		footer = {
			format = "{{backlinks}} backlinks  {{properties}} properties  {{words}} words  {{chars}} chars",
			enabled = true,
		},
	},
}
