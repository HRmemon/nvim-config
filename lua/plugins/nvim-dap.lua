return {
	"mfussenegger/nvim-dap",
	event = "VeryLazy",
	-- Copied from LazyVim/lua/lazyvim/plugins/extras/dap/core.lua and
	-- modified.
	keys = {
		{
			"<F9>",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle Breakpoint",
		},

		{
			"<F5>",
			function()
				require("dap").continue()
			end,
			desc = "Continue",
		},

		{
			"<leader>dC",
			function()
				require("dap").run_to_cursor()
			end,
			desc = "Run to Cursor",
		},

		{
			"<F6>",
			function()
				require("dap").terminate()
			end,
			desc = "Terminate",
		},
		{
			"<F7>",
			function()
				require("dap").step_into()
			end,
			desc = "Step Into",
		},
		{
			"<F8>",
			function()
				require("dap").step_over()
			end,
			desc = "Step Over",
		},
		{
			"<leader>dO",
			function()
				require("dap").step_out()
			end,
			desc = "Step Out",
		},
	},
}
