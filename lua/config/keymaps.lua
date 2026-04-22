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
-- Run ctx as a shell command when pressing F3
vim.keymap.set("n", "<F3>", ":!ctx<CR>", { noremap = true, silent = true, desc = "Run ctx shell command" })

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
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bo", function()
  Snacks.bufdelete.other()
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
    Snacks.lazygit({ cwd = git_root or vim.loop.cwd() })
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
local function toggle_terminal()
  local git_root = require("utils.git").get_git_root()
  Snacks.terminal.toggle(nil, { cwd = git_root or vim.loop.cwd() })
end
vim.keymap.set({ "n", "i", "v", "t" }, "<C-_>", toggle_terminal, { desc = "Toggle Terminal (Git Root or CWD)" })
vim.keymap.set({ "n", "i", "v", "t" }, "<C-/>", toggle_terminal, { desc = "Toggle Terminal (Git Root or CWD)" })
vim.keymap.set("t", "<Esc><Esc>", "<cmd>close<cr>", { desc = "Hide Terminal" }) -- Use double-escape to exit

-- Git
-- vim.keymap.set(
-- 	"n",
-- 	"<leader>gdw",
-- 	":tab Git diff --word-diff<CR>",
-- 	{ noremap = true, silent = true, desc = "Git Word Diff" }
-- )

-- Package Management
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy Package Manager" })
vim.keymap.set("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason Installer" })

-- Custom Scripting
vim.keymap.set("n", "<leader>an", swap_path_line, { noremap = true, desc = "Swap File Path (Current Line)" })
vim.keymap.set("n", "<leader>aN", swap_paths_file, { noremap = true, desc = "Swap File Paths (Entire File)" })
vim.keymap.set("i", "{<CR>", "{<CR>}<Esc>O", { noremap = true })
vim.keymap.set("i", "(<CR>", "(<CR>)<Esc>O", { noremap = true })
vim.keymap.set("i", "[<CR>", "[<CR>]<Esc>O", { noremap = true })

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

-- Operator function that handles the actual checkbox toggling
local function toggle_checkbox(motion)
  local start_line, end_line

  if motion then
    -- Use marks from operator-pending mode
    start_line = vim.api.nvim_buf_get_mark(0, "[")[1]
    end_line = vim.api.nvim_buf_get_mark(0, "]")[1]
  else
    -- Single line operation
    start_line = vim.fn.line(".")
    end_line = start_line
  end

  for lnum = start_line, end_line do
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
    if line:match("^%- %[.].*") then
      -- Remove checkbox
      line = line:gsub("^%- %[.]", "", 1):gsub("^%s+", "", 1)
    else
      -- Add checkbox
      line = "- [ ] " .. line
    end
    vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { line })
  end
end

-- Wrapper function for operator-pending mode
local function toggle_checkbox_op()
  vim.o.operatorfunc = "v:lua.toggle_checkbox"
  return "g@"
end

-- Set up mappings
vim.keymap.set("n", "<leader>mc", toggle_checkbox_op, { expr = true, desc = "Add/Remove markdown checkbox" })
vim.keymap.set("x", "<leader>mc", function()
  toggle_checkbox(vim.fn.visualmode())
end, { desc = "Add/Remove markdown checkbox in visual mode" })

function markdown_toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  if line:match("^%- %[.].*") then
    line = line:gsub("^%- %[.]", "", 1):gsub("^%s+", "", 1)
  else
    line = "- [ ] " .. line
  end
  vim.api.nvim_set_current_line(line)
end

-- tiny checkbox helpers (drop into init.lua)
-- requires: tpope/vim-repeat

local function add_remove_checkbox()
  local line = vim.api.nvim_get_current_line()
  local indent = line:match("^(%s*)") or ""
  local rest = line:sub(#indent + 1)

  -- if line already starts with "- [ ]" or "- [x]" (case-insensitive)
  local head5 = rest:sub(1, 5)
  if head5 == "- [ ]" or head5:lower() == "- [x]" then
    local off = 5
    if rest:sub(6, 6) == " " then
      off = 6
    end -- remove trailing space if present
    local newrest = rest:sub(off + 1) or ""
    vim.api.nvim_set_current_line(indent .. newrest)
  else
    -- add checkbox after indent
    vim.api.nvim_set_current_line(indent .. "- [ ] " .. rest)
  end
end

local function toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  local indent = line:match("^(%s*)") or ""
  local rest = line:sub(#indent + 1)
  local head5 = rest:sub(1, 5)

  if head5 == "- [ ]" then
    local suffix = rest:sub(6) or ""
    vim.api.nvim_set_current_line(indent .. "- [x]" .. suffix)
  elseif head5:lower() == "- [x]" then
    local suffix = rest:sub(6) or ""
    vim.api.nvim_set_current_line(indent .. "- [ ]" .. suffix)
  end
end

-- Create <Plug> mappings that call the functions and register for repeat
vim.keymap.set("n", "<Plug>(AddRemoveCheckbox)", function()
  add_remove_checkbox()
  -- register the <Plug> mapping with repeat.vim (use replace_termcodes)
  vim.fn["repeat#set"](vim.api.nvim_replace_termcodes("<Plug>(AddRemoveCheckbox)", true, false, true))
end, { silent = true, noremap = true })

vim.keymap.set("n", "<Plug>(ToggleCheckbox)", function()
  toggle_checkbox()
  vim.fn["repeat#set"](vim.api.nvim_replace_termcodes("<Plug>(ToggleCheckbox)", true, false, true))
end, { silent = true, noremap = true })

-- Map your leader keys to those <Plug> mappings (use remap so <Plug> is invoked)
vim.keymap.set("n", "<leader>oc", "<Plug>(AddRemoveCheckbox)", { remap = true, silent = true })
vim.keymap.set("n", "<leader>ot", "<Plug>(ToggleCheckbox)", { remap = true, silent = true })


local function fff_grep_selection_or_word()
  local query
  local mode = vim.fn.mode()

  if mode == "v" or mode == "V" then
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local lines = vim.api.nvim_buf_get_text(
      0,
      start_pos[2] - 1,
      start_pos[3] - 1,
      end_pos[2] - 1,
      end_pos[3],
      {}
    )
    query = table.concat(lines, "\n")
  end

  query = (query and query ~= "") and query or vim.fn.expand("<cword>")
  require("fff").live_grep({ query = query })
end

-- Top Pickers & Explorer
-- FFF trial mappings (old Snacks equivalents kept below as comments for easy rollback)
vim.keymap.set("n", "<leader><space>", function() require("fff").find_files() end, { desc = "Smart Find Files" })
vim.keymap.set("n", "<leader>,", function() Snacks.picker.buffers() end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", function() require("fff").live_grep() end, { desc = "Grep" })
vim.keymap.set("n", "<leader>:", function() Snacks.picker.command_history() end, { desc = "Command History" })
vim.keymap.set("n", "<leader>n", function() Snacks.picker.notifications() end, { desc = "Notification History" })
vim.keymap.set("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fc", function() require("fff").find_files_in_dir(vim.fn.stdpath("config")) end,
  { desc = "Find Config File" })
vim.keymap.set("n", "<leader>ff", function() require("fff").find_files() end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", function() Snacks.picker.git_files() end, { desc = "Find Git Files" })
vim.keymap.set("n", "<leader>fp", function() Snacks.picker.projects() end, { desc = "Projects" })
vim.keymap.set("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent" })
vim.keymap.set("n", "<leader>gb", function() Snacks.picker.git_branches() end, { desc = "Git Branches" })
vim.keymap.set("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git Log" })
vim.keymap.set("n", "<leader>gL", function() Snacks.picker.git_log_line() end, { desc = "Git Log Line" })
vim.keymap.set("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git Status" })
vim.keymap.set("n", "<leader>gS", function() Snacks.picker.git_stash() end, { desc = "Git Stash" })
vim.keymap.set("n", "<leader>gd", function() Snacks.picker.git_diff() end, { desc = "Git Diff (Hunks})" })
vim.keymap.set("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Log File" })
vim.keymap.set("n", "<leader>sb", function() Snacks.picker.lines() end, { desc = "Buffer Lines" })
vim.keymap.set("n", "<leader>sB", function() Snacks.picker.grep_buffers() end, { desc = "Grep Open Buffers" })
vim.keymap.set("n", "<leader>sg", function() require("fff").live_grep() end, { desc = "Grep" })
vim.keymap.set({ "n", "x" }, "<leader>sw", fff_grep_selection_or_word,
  { desc = "Visual selection or word", })
-- vim.keymap.set("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "Smart Find Files" })
-- vim.keymap.set("n", "<leader>/", function() Snacks.picker.grep() end, { desc = "Grep" })
-- vim.keymap.set("n", "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,
--   { desc = "Find Config File" })
-- vim.keymap.set("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files" })
-- vim.keymap.set("n", "<leader>sg", function() Snacks.picker.grep() end, { desc = "Grep" })
-- vim.keymap.set({ "n", "x" }, "<leader>sw", function() Snacks.picker.grep_word() end,
--   { desc = "Visual selection or word", })
vim.keymap.set("n", '<leader>s"', function() Snacks.picker.registers() end, { desc = "Registers" })
vim.keymap.set("n", '<leader>s/', function() Snacks.picker.search_history() end, { desc = "Search History" })
vim.keymap.set("n", "<leader>sa", function() Snacks.picker.autocmds() end, { desc = "Autocmds" })
vim.keymap.set("n", "<leader>sb", function() Snacks.picker.lines() end, { desc = "Buffer Lines" })
vim.keymap.set("n", "<leader>sc", function() Snacks.picker.command_history() end, { desc = "Command History" })
vim.keymap.set("n", "<leader>sC", function() Snacks.picker.commands() end, { desc = "Commands" })
vim.keymap.set("n", "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
vim.keymap.set("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "Help Pages" })
vim.keymap.set("n", "<leader>sH", function() Snacks.picker.highlights() end, { desc = "Highlights" })
vim.keymap.set("n", "<leader>si", function() Snacks.picker.icons() end, { desc = "Icons" })
vim.keymap.set("n", "<leader>sj", function() Snacks.picker.jumps() end, { desc = "Jumps" })
vim.keymap.set("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>sl", function() Snacks.picker.loclist() end, { desc = "Location List" })
vim.keymap.set("n", "<leader>sm", function() Snacks.picker.marks() end, { desc = "Marks" })
vim.keymap.set("n", "<leader>sM", function() Snacks.picker.man() end, { desc = "Man Pages" })
vim.keymap.set("n", "<leader>sp", function() Snacks.picker.lazy() end, { desc = "Search for Plugin Spec" })
vim.keymap.set("n", "<leader>sq", function() Snacks.picker.qflist() end, { desc = "Quickfix List" })
vim.keymap.set("n", "<leader>sR", function() Snacks.picker.resume() end, { desc = "Resume" })
vim.keymap.set("n", "<leader>su", function() Snacks.picker.undo() end, { desc = "Undo History" })
vim.keymap.set("n", "<leader>uC", function() Snacks.picker.colorschemes() end, { desc = "Colorschemes" })
vim.keymap.set("n", "<leader>st", function() Snacks.picker.todo_comments() end, { desc = "Todo" })
-- LSP Navigation
vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
vim.keymap.set("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Goto Declaration" })
vim.keymap.set("n", "gr", function() Snacks.picker.lsp_references() end, { nowait = true, desc = "References" })
vim.keymap.set("n", "gi", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
vim.keymap.set("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto T[y]pe Definition" })
vim.keymap.set("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
vim.keymap.set("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols" })

-- LSP Actions
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set({ "n", "v" }, "<leader>ca", function()
  if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
    vim.lsp.buf.range_code_action()
  else
    vim.lsp.buf.code_action()
  end
end, { desc = "Code Actions" })

-- LSP Workspace
vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add Workspace Folder" })
vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove Workspace Folder" })
vim.keymap.set("n", "<leader>wl", function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, { desc = "List Workspace Folders" })

-- Inlay Hints Toggle (Neovim 0.10+)
if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
  vim.keymap.set("n", "<leader>uh", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  end, { desc = "Toggle Inlay Hints" })
end
vim.keymap.set("n", "<leader>*", function()
  require("fff").live_grep({ query = vim.fn.expand("<cword>") })
end, { desc = "Search word under cursor across project" })
-- vim.keymap.set("n", "<leader>*", function()
--   Snacks.picker.grep_word()
-- end, { desc = "Search word under cursor across project" })

-- Todo Comments
vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })
-- Quick Access Terminal
-- vim.keymap.set("n", "<F4>", function()
--   local dir
--   if vim.bo.filetype == "oil" then
--     dir = vim.fn.expand("%:p")   -- oil buffer = directory itself
--   else
--     dir = vim.fn.expand("%:p:h") -- normal file buffer
--   end
--   dir = dir ~= "" and dir or vim.loop.cwd()
--
--   vim.fn.setreg("+", dir)
-- end, { desc = "Toggle Quick Access Terminal" })



local function jq_error_jump()
  local file = vim.fn.expand("%:p")
  if file == "" then
    print("No file")
    return
  end

  local cmd = "jq length < " .. vim.fn.shellescape(file)
  local output = vim.fn.system(cmd)

  local line, col = output:match("line (%d+), column (%d+)")
  if line and col then
    line = tonumber(line)
    col = tonumber(col)

    local line_text = vim.fn.getline(line)
    local line_len = #line_text

    -- Decide how to jump
    -- if col <= 1 then
    --   vim.api.nvim_win_set_cursor(0, { line, 0 })
    --   vim.notify("jq error at start of line " .. line, vim.log.levels.ERROR)
    -- elseif col >= line_len - 1 then
    --   vim.api.nvim_win_set_cursor(0, { line, line_len })
    --   vim.notify("jq error at end of line " .. line, vim.log.levels.ERROR)
    -- else
    vim.api.nvim_win_set_cursor(0, { line, col - 1 })
    vim.notify("Jumped to jq error at line " .. line .. ", col " .. col .. "\n" .. output, vim.log.levels.ERROR)
    -- end
  else
    vim.notify(output, vim.log.levels.INFO)
  end
end

vim.keymap.set("n", "<F4>", jq_error_jump, { desc = "Jump to jq error in JSON file" })
