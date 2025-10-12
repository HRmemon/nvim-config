return {
	"linux-cultist/venv-selector.nvim",
	event = "VeryLazy", -- or on specific filetypes, e.g., event = "FileType python"
	dependencies = {
		"neovim/nvim-lspconfig",
	},
	ft = "python", -- Load when opening Python files
	keys = {
		{ ",v", "<cmd>VenvSelect<cr>" }, -- Open picker on keymap
	},
	opts = { -- this can be an empty lua table - just showing below for clarity.
		search = {}, -- if you add your own searches, they go here.
		options = {}, -- if you add plugin options, they go here.
	},
}
