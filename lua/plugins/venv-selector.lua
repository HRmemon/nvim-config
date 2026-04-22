return {
	"linux-cultist/venv-selector.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
	},
	-- Only load on keypress, not on file open
	keys = {
		{ ",v", "<cmd>VenvSelect<cr>", ft = "python", desc = "Select Python venv" },
	},
	opts = {
		settings = {
			search = {
				project_venvs = {
					command = "fd -HI -a -td --max-depth 2 -E __pycache__ -E .git ^(env|venv|\\.venv)$ .",
				},
			},
		},
	},
}
