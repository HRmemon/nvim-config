return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		plugins = {
			marks = true, -- shows a list of your marks on ' and `
			registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
			-- the presets plugin, adds help for a bunch of default keybindings in Neovim
			-- No actual key bindings are created
			spelling = {
				enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
				suggestions = 20, -- how many suggestions should be shown in the list?
			},
			presets = {
				operators = true, -- adds help for operators like d, y, ...
				motions = true, -- adds help for motions
				text_objects = true, -- help for text objects triggered after entering an operator
				windows = true, -- default bindings on <c-w>
				nav = true, -- misc bindings to work with windows
				z = true, -- bindings for folds, spelling and others prefixed with z
				g = true, -- bindings for prefixed with g
			},
		},
		preset = "helix",
		-- Configure the floating window
		win = {
			-- don't allow the popup to overlap with the cursor
			no_overlap = true,
			-- width = 1,
			-- height = { min = 4, max = 25 },
			-- col = 0,
			-- row = math.huge,
			border = "single",
			padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
			title = true,
			title_pos = "center",
			zindex = 1000,
			-- Additional vim.wo and vim.bo options
			bo = {},
			wo = {
				-- winblend = 10, -- value between 0-100 0 for fully opaque and 100 for fully transparent
			},
		},
		layout = {
			width = { min = 20 }, -- min and max width of the columns
			spacing = 3, -- spacing between columns
		},
		icons = {
			breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
			separator = "➜", -- symbol used between a key and it's label
			group = "+", -- symbol prepended to a group
			ellipsis = "…",
			-- set to false to disable all mapping icons,
			-- both those explicitly added in a mapping
			-- and those from rules
			mappings = true,
			--- See `lua/which-key/icons.lua` for more details
			--- Set to `false` to disable keymap icons from rules
			---@type wk.IconRule[]|false
			rules = {},
			-- use the highlights from mini.icons
			-- When `false`, it will use `WhichKeyIcon` instead
			colors = true,
			-- used by key format
			keys = {
				Up = " ",
				Down = " ",
				Left = " ",
				Right = " ",
				C = "󰘴 ",
				M = "󰘵 ",
				D = "󰘳 ",
				S = "󰘶 ",
				CR = "󰌑 ",
				Esc = "󱊷 ",
				ScrollWheelDown = "󱕐 ",
				ScrollWheelUp = "󱕑 ",
				NL = "󰌑 ",
				BS = "󰁮",
				Space = "󱁐 ",
				Tab = "󰌒 ",
				F1 = "󱊫",
				F2 = "󱊬",
				F3 = "󱊭",
				F4 = "󱊮",
				F5 = "󱊯",
				F6 = "󱊰",
				F7 = "󱊱",
				F8 = "󱊲",
				F9 = "󱊳",
				F10 = "󱊴",
				F11 = "󱊵",
				F12 = "󱊶",
			},
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
