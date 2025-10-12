return {
	"ibhagwan/fzf-lua",
	event = "VeryLazy",
	-- We already fixed the dependencies, so this part is correct.
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		{
			"elanmed/fzf-lua-frecency.nvim",
			config = function()
				require("fzf-lua-frecency").setup({
					db_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "fzf-lua-frecency"),
				})
			end,
		},
	},
	-- We add keymaps here to define how to trigger fzf-lua.
	keys = function()
		-- This is how you correctly use your local module!
		local git_utils = require("utils.git")

		return {
			-- Smart Open using Frecency (recently and frequently used files)
			{
				"<leader><leader>",
				function()
					require("fzf-lua-frecency").frecency({
						-- We use our utility to search only within the current git project
						cwd = git_utils.get_git_root(),
						cwd_only = true,
						previewer = false,
					})
				end,
				desc = "Smart Open (Project Frecency)",
			},
			-- Find any file in the project
			{
				"<leader>ff",
				function()
					require("fzf-lua").files({
						cwd = git_utils.get_git_root(),
						fd_opts = [[--color=never --hidden --type f --type l --exclude .git --no-ignore]],
					})
				end,
				desc = "Find Files (Project)",
			},
			-- Grep (search for text) in the project
			{
				"<leader>/",
				function()
					require("fzf-lua").live_grep({
						cwd = git_utils.get_git_root(),
						exec_empty_query = true,
					})
				end,
				desc = "Live Grep (Project)",
			},
			-- Other useful finders
			{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find Buffers" },
			{ "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Find Git Files" },
			{ "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Find Help Tags" },
			{ "<leader>sR", "<cmd>FzfLua resume<cr>", desc = "Resume last fzf-lua picker" },
			{ "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Find Recent Files" },
			{ "<leader>fc", "<cmd>FzfLua commands<cr>", desc = "Find Commands" },
			{ "<leader>fm", "<cmd>FzfLua marks<cr>", desc = "Find Marks" },
			{ '<leader>s"', "<cmd>FzfLua registers<cr>", desc = "Show all registers" },

			--- git
			{ "<leader>gb", "<cmd>FzfLua git_branches<cr>", desc = "Git Branches" },
			{ "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Git Commits" },
			{ "<leader>gd", "<cmd>FzfLua git_diff<cr>", desc = "Git Diff" },
			{ "<leader>gs", "<cmd>FzfLua git_status<cr>", desc = "Git Status" },

			-- dap
			{ "<leader>df", "<cmd>FzfLua dap_breakpoints<cr>", desc = "DAP Breakpoints" },

			-- keymaps
			{ "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Show all keymaps" },
		}
	end,
	config = function()
		require("fzf-lua").setup({
			"max-perf",
			fzf_colors = true,
			keymap = {
				fzf = { ["ctrl-q"] = "select-all+accept" },
			},
		})
		require("fzf-lua").register_ui_select()
	end,
}
