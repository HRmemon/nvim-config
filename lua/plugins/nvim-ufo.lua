return {
	"kevinhwang91/nvim-ufo",
	event = "BufReadPost",
	dependencies = { "kevinhwang91/promise-async" },
	config = function()
		-- fold settings
		vim.o.foldcolumn = "1"
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true

		require("ufo").setup({
			-- Only two providers: main + fallback
			provider_selector = function(bufnr, filetype, buftype)
				-- prefer LSP if available, else fallback to indent
				return { "lsp", "indent" }
			end,
		})

		-- keymaps
		vim.keymap.set("n", "zR", require("ufo").openAllFolds)
		vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
	end,
}
