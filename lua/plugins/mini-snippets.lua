return {
	"nvim-mini/mini.snippets",
	event = "VeryLazy",
	version = false, -- always get latest
	config = function()
		local gen_loader = require("mini.snippets").gen_loader

		require("mini.snippets").setup({
			snippets = {
				-- Load custom global snippets
				gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/global.json"),

				-- Load language-specific snippets (like typescript.json)
				gen_loader.from_lang(),
			},
		})
		require("mini.snippets").start_lsp_server()
	end,
}
