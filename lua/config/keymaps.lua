-- =============================================================================
-- Keymaps
-- =============================================================================
-- This file organizes all custom keymaps for Neovim.
-- Keymaps are grouped by functionality for easier navigation and maintenance.
--
-- For default LazyVim keymaps, see:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- =============================================================================
-- Custom Functions
-- =============================================================================
-- All helper functions used by the keymaps below are defined in this section.
--- Copies the content of all listed buffers into the system clipboard.
local function copy_buffers_to_clipboard()
	local buffers = vim.fn.getbufinfo({ buflisted = 1, bufloaded = 1 })
	if not buffers or #buffers == 0 then
		vim.notify("No listed buffers to copy.", vim.log.levels.WARN)
		return
	end

	local contents = {}
	for _, buf in ipairs(buffers) do
		local lines = vim.api.nvim_buf_get_lines(buf.bufnr, 0, -1, false)
		table.insert(contents, table.concat(lines, "\n"))
	end

	local all_text = table.concat(contents, "\n\n--- Buffer Separator ---\n\n")
	vim.fn.setreg("+", all_text)
	vim.notify("Copied " .. #buffers .. " buffer(s) to system clipboard.", vim.log.levels.INFO)
end
--- Swaps predefined file paths on the current line.
local function swap_path_line()
	local paths = {
		["/home/safi/safihasanfaraz%-share"] = "/home/hassan/sharefiles-text",
		["/home/hassan/sharefiles%-text"] = "/home/safi/safihasanfaraz-share",
	}
	local line = vim.api.nvim_get_current_line()
	local new_line = line

	for from_path, to_path in pairs(paths) do
		if line:find(from_path) then
			new_line = line:gsub(from_path, to_path)
			break
		end
	end

	if new_line ~= line then
		vim.api.nvim_set_current_line(new_line)
		vim.notify("Path swapped on current line.", vim.log.levels.INFO)
	else
		vim.notify("No matching path found on this line.", vim.log.levels.WARN)
	end
end

--- Swaps predefined file paths throughout the entire buffer.
local function swap_paths_file()
	local paths = {
		["/home/safi/safihasanfaraz%-share"] = "/home/hassan/sharefiles-text",
		["/home/hassan/sharefiles%-text"] = "/home/safi/safihasanfaraz-share",
	}
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local changes_made = false
	local modified_lines = {}

	for _, line in ipairs(lines) do
		local new_line = line
		for from_path, to_path in pairs(paths) do
			if line:find(from_path) then
				new_line = line:gsub(from_path, to_path)
				changes_made = true
				break -- Only apply the first match per line
			end
		end
		table.insert(modified_lines, new_line)
	end

	if changes_made then
		vim.api.nvim_buf_set_lines(0, 0, -1, false, modified_lines)
		vim.notify("All matching paths swapped in the file.", vim.log.levels.INFO)
	else
		vim.notify("No matching paths found in the file.", vim.log.levels.WARN)
	end
end

--- Smartly wraps the current line in Markdown comment syntax if not already commented.
vim.api.nvim_create_user_command("SmartMdComment", function()
	local line = vim.fn.getline(".")
	if not line:match("^%s*<!%-%-") and not line:match("%-%->%s*$") then
		local commented = string.format("<!-- `%s` -->", vim.trim(line))
		vim.fn.setline(".", commented)
	end
end, {})

--- Dynamic 'gf' that resolves variables in a path before opening the file.
local function dynamic_gf()
	local function resolve_var(var)
		-- 1) Scan upwards in the current buffer for the variable definition
		local cur_line_num = vim.api.nvim_win_get_cursor(0)[1]
		local lines = vim.api.nvim_buf_get_lines(0, 0, cur_line_num, false)
		for i = #lines, 1, -1 do
			local line = lines[i]
			local dbl = line:match(var .. '%s*=%s*"([^"]+)"')
			local sng = line:match(var .. "%s*=%s*'([^']+)'")
			if dbl or sng then
				return dbl or sng
			end
		end

		-- 2) Fallback to LSP definition if not found locally
		local clients = vim.lsp.get_active_clients({ bufnr = 0 })
		if #clients == 0 then
			return nil, "no active LSP client"
		end
		local client = clients[1]
		local enc = client.offset_encoding or "utf-16"
		local params = vim.lsp.util.make_position_params(nil, enc)
		local results = vim.lsp.buf_request_sync(0, "textDocument/definition", params, 500)
		if not results then
			return nil, "no LSP definition found"
		end

		for _, resp in pairs(results) do
			for _, loc in ipairs(resp.result or {}) do
				local bufnr = vim.fn.bufnr(vim.fn.uri_to_fname(loc.uri))
				vim.api.nvim_buf_load(bufnr)
				local line = vim.api.nvim_buf_get_lines(bufnr, loc.range.start.line, loc.range.start.line + 1, false)[1]
					or ""
				local dbl, sng = line:match('"(.-)"'), line:match("'(.-)'")
				if dbl or sng then
					return dbl or sng
				end
			end
		end

		return nil, "no string literal found in definition"
	end

	local target = vim.fn.expand("<cWORD>")
	local has_vars = false
	local real_path, err_msg = target:gsub("{(.-)}", function(var)
		has_vars = true
		local val, err = resolve_var(var)
		if not val then
			err_msg = ("Could not resolve {%s}: %s"):format(var, err)
			return "{" .. var .. "}" -- Return original if unresolved
		end
		return val
	end)

	if err_msg then
		vim.notify(err_msg, vim.log.levels.WARN)
		return -- Abort if any variable failed to resolve
	end

	if not has_vars then
		vim.cmd("normal! gf") -- No variables found, use standard gf
	else
		vim.cmd("edit " .. vim.fn.fnameescape(real_path))
	end
end

-- =============================================================================
-- Core Editing & Navigation
-- =============================================================================

-- Clipboard
vim.keymap.set({ "n", "x" }, "<leader>r", 'ggVG"+p', { desc = "Replace File with System Clipboard" })
vim.keymap.set(
	"n",
	"<F1>",
	":%y+<CR>",
	{ noremap = true, silent = true, desc = "Yank Entire File to System Clipboard" }
)
vim.keymap.set("n", "<F2>", function()
	local filepath = vim.fn.expand("%:p")
	vim.fn.setreg("+", filepath)
	vim.notify("Copied file path: " .. filepath)
end, { desc = "Copy Full File Path to Clipboard" })

-- Scrolling & Motion
vim.keymap.set({ "n", "x" }, "<C-d>", "<C-d>zz", { desc = "Scroll Down and Center" })
vim.keymap.set({ "n", "x" }, "<C-u>", "<C-u>zz", { desc = "Scroll Up and Center" })
vim.keymap.set(
	{ "n", "x" },
	"j",
	"v:count == 0 ? 'gj' : 'j'",
	{ expr = true, silent = true, desc = "Down (Handles Wrapped Lines)" }
)
vim.keymap.set(
	{ "n", "x" },
	"k",
	"v:count == 0 ? 'gk' : 'k'",
	{ expr = true, silent = true, desc = "Up (Handles Wrapped Lines)" }
)
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join Lines Without Moving Cursor" })

-- Search
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Text Objects
vim.keymap.set({ "o", "x" }, "ig", ":<C-u>normal! ggVG<CR>", { desc = "Select Entire File Text Object" })

-- Miscellaneous Editing
vim.keymap.set({ "i", "n" }, "<esc>", "<esc><cmd>noh<cr>", { desc = "Escape and Clear Search Highlight" })
vim.keymap.set("n", "Q", "q", { noremap = true, desc = "Disable Ex Mode" })
vim.keymap.set("n", "<leader>sc", ":SmartMdComment<CR>", { desc = "Smart Comment Markdown Line" })
vim.keymap.set("n", "gF", dynamic_gf, { noremap = true, silent = true, desc = "Go to File (Dynamic Path)" })
vim.keymap.set({ "n", "x", "i" }, "<C-s>", "<esc>:w<cr>", { desc = "Saves the file" })

-- =============================================================================
-- Window & Buffer Management
-- =============================================================================

-- Window Navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Window Actions
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All Windows" })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split Window Vertically", remap = true })
vim.keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete/Close Window", remap = true })
vim.keymap.set("n", "<leader>wo", "<C-W>o", { desc = "Close Other Windows", remap = true })

-- Buffer Actions
vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File (Buffer)" })
vim.keymap.set("n", "<leader>bd", function()
	require("snacks").bufdelete()
end, { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bo", function()
	require("snacks").bufdelete.other()
end, { desc = "Delete Other Buffers" })
vim.keymap.set("n", "<leader>by", copy_buffers_to_clipboard, { desc = "Copy All Buffers to Clipboard" })

-- =============================================================================
-- Plugin Keymaps
-- =============================================================================

-- Code Companion (AI)
vim.keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Code Companion Chat" })
vim.keymap.set("n", "<leader>ai", "<cmd>CodeCompanionActions<cr>", { desc = "Code Companion Actions" })

-- Diagnostics
vim.keymap.set("n", "]d", function()
	vim.diagnostic.goto_next()
end, { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", function()
	vim.diagnostic.goto_prev()
end, { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next({ severity = "ERROR" })
end, { desc = "Next Error" })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev({ severity = "ERROR" })
end, { desc = "Prev Error" })
vim.keymap.set("n", "]w", function()
	vim.diagnostic.goto_next({ severity = "WARN" })
end, { desc = "Next Warning" })
vim.keymap.set("n", "[w", function()
	vim.diagnostic.goto_prev({ severity = "WARN" })
end, { desc = "Prev Warning" })

-- Noice (UI Enhancements)
vim.keymap.set("c", "<S-Enter>", function()
	require("noice").redirect(vim.fn.getcmdline())
end, { desc = "Redirect Cmdline to Noice" })
vim.keymap.set("n", "<leader>snl", function()
	require("noice").cmd("last")
end, { desc = "Noice Last Message" })
vim.keymap.set("n", "<leader>snh", function()
	require("noice").cmd("history")
end, { desc = "Noice History" })
vim.keymap.set("n", "<leader>sna", function()
	require("noice").cmd("all")
end, { desc = "Noice All" })
vim.keymap.set("n", "<leader>snd", function()
	require("noice").cmd("dismiss")
end, { desc = "Noice Dismiss All" })

-- Quickfix List
vim.keymap.set("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Open Quickfix List" })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>", { desc = "Previous Quickfix Item" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Next Quickfix Item" })

-- Snacks / Lazygit
if vim.fn.executable("lazygit") == 1 then
	vim.keymap.set("n", "<leader>gg", function()
		local git_root = require("utils.git").get_git_root()
		require("snacks").lazygit({ cwd = git_root or vim.loop.cwd() })
	end, { desc = "Lazygit (Smart CWD)" })
end

-- fugitive
vim.keymap.set("n", "<leader>gv", "<cmd>Gvdiffsplit<cr>", { desc = "Git Vertical Diff" })

-- =============================================================================
-- Utility & Miscellaneous
-- =============================================================================

-- Toggle Settings
vim.keymap.set("n", "<leader>uw", function()
	vim.wo.wrap = not vim.wo.wrap
	vim.notify("Wrap: " .. (vim.wo.wrap and "ON" or "OFF"))
end, { desc = "Toggle Wrap" })

local diagnostics_active = true
vim.keymap.set("n", "<leader>ud", function()
	diagnostics_active = not diagnostics_active
	vim.diagnostic.enable(diagnostics_active)
	vim.notify("Diagnostics " .. (diagnostics_active and "Enabled" or "Disabled"), vim.log.levels.INFO)
end, { desc = "Toggle Diagnostics" })

-- Terminals
vim.keymap.set("n", "<leader>fz", "<cmd>FloatermToggle<cr>", { desc = "Toggle Floaterm" })
vim.keymap.set({ "n", "i", "v", "t" }, "<C-/>", function()
	local git_root = require("utils.git").get_git_root()
	require("snacks").terminal.toggle(nil, { cwd = git_root or vim.loop.cwd() })
end, { desc = "Toggle Terminal (Git Root or CWD)" })
vim.keymap.set("t", "<Esc><Esc>", "<cmd>close<cr>", { desc = "Hide Terminal" }) -- Use double-escape to exit

-- Git
vim.keymap.set(
	"n",
	"<leader>gdw",
	":tab Git diff --word-diff<CR>",
	{ noremap = true, silent = true, desc = "Git Word Diff" }
)

-- Package Management
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy Package Manager" })
vim.keymap.set("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason Installer" })

-- Custom Scripting
vim.keymap.set("n", "<leader>an", swap_path_line, { noremap = true, desc = "Swap File Path (Current Line)" })
vim.keymap.set("n", "<leader>aN", swap_paths_file, { noremap = true, desc = "Swap File Paths (Entire File)" })

----- Persistence (folke : session management)
-- Restore session for current directory
vim.keymap.set("n", "<leader>qs", function()
	require("persistence").load()
end, { desc = "Restore session" })

-- Restore last session
vim.keymap.set("n", "<leader>ql", function()
	require("persistence").load({ last = true })
end, { desc = "Restore last session" })

-- Select a session to load
vim.keymap.set("n", "<leader>qS", function()
	require("persistence").select()
end, { desc = "Select session" })

-- Stop saving sessions
vim.keymap.set("n", "<leader>qd", function()
	require("persistence").stop()
end, { desc = "Stop session saving" })

-- Treesitter Objects

-- ====== from folke directly ======
-- commenting
vim.keymap.set("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
vim.keymap.set("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- tabs
vim.keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
vim.keymap.set("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
vim.keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Treesitter Textobjects
-- vim.keymap.set({ "o", "x" }, "af", "Treesitter Function (around)")
-- vim.keymap.set({ "o", "x" }, "if", "Treesitter Function (inside)")
-- vim.keymap.set({ "o", "x" }, "ac", "Treesitter Class (around)")
-- vim.keymap.set({ "o", "x" }, "ic", "Treesitter Class (inside)")

-- =============================================================================
-- Legacy / Commented-Out
-- =============================================================================
-- These are keymaps you had previously but are currently disabled.

-- --- REPL Integration (Iron.nvim)
-- vim.keymap.set("n", "<F1>", "<leader>tl", { desc = "Send current line to REPL with Iron.nvim" })
-- vim.keymap.set("i", "<F2>", "<Esc><F1>i", { desc = "Send current line to REPL in insert mode with Iron.nvim" })

-- --- REPL Integration (molten-nvim)
-- vim.keymap.set("n", "<leader>m", ":MoltenEvaluateLine<CR>", { silent = true, desc = "evaluate line" })
-- vim.keymap.set(
--   "x",
--   "<leader>m",
--   ":<C-u>MoltenEvaluateVisual<CR>gv<Esc>",
--   { silent = true, desc = "evaluate visual selection" }
-- )

-- --- Move lines with Alt key (can conflict with terminal emulators)
-- vim.keymap.set("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
-- vim.keymap.set("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
-- vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
-- vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
-- vim.keymap.set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
-- vim.keymap.set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- --- Alternative bufferline mappings (might be handled by another plugin)
-- vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
-- vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
