-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { noremap = true, desc = "yank in sys clip" })
vim.keymap.set({ "n", "x" }, "<leader>p", '"+p', { desc = "paste from sys clip" })
vim.keymap.set({ "n", "x" }, "<leader>r", 'ggVG"+p', { desc = "replace file" })
vim.keymap.set({ "n", "x" }, "<C-d>", "<C-d>zz")
vim.keymap.set({ "n", "x" }, "<C-u>", "<C-u>zz")
vim.keymap.set("n", "Q", "q", { noremap = true })
vim.api.nvim_set_keymap("n", "<F1>", ":%y+<CR>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<F1>", "<leader>tl", { desc = "Send current line to REPL with Iron.nvim" })
-- vim.keymap.set("i", "<F2>", "<Esc><F1>i", { desc = "Send current line to REPL in insert mode with Iron.nvim" })

--- molten
-- vim.keymap.set("n", "<leader>m", ":MoltenEvaluateLine<CR>", { silent = true, desc = "evaluate line" })
-- vim.keymap.set(
--   "x",
--   "<leader>m",
--   ":<C-u>MoltenEvaluateVisual<CR>gv<Esc>",
--   { silent = true, desc = "evaluate visual selection" }
-- )

vim.keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Code Companion Chat" })
vim.keymap.set("n", "<leader>ai", "<cmd>CodeCompanionActions<cr>", { desc = "Code Companion Actions" })

vim.keymap.set("n", "<leader>fz", "<cmd>FloatermToggle<cr>", { desc = "Code Companion Actions" })


function _G.copy_buffers_to_clipboard()
  -- Get all loaded, listed buffers
  local buffers = vim.fn.getbufinfo({ buflisted = 1, bufloaded = 1 })

  local contents = {}
  for _, buf in ipairs(buffers) do
    -- Get buffer content (including unsaved changes)
    local lines = vim.api.nvim_buf_get_lines(buf.bufnr, 0, -1, false)
    table.insert(contents, table.concat(lines, "\n"))
  end

  -- Combine all buffers' content
  local all_text = table.concat(contents, "\n")

  -- Copy to clipboard using wl-copy
  vim.fn.setreg("+", all_text)
  vim.notify("Copied " .. #buffers .. " buffer(s) to clipboard!")
end

vim.keymap.set("n", "<leader>by", copy_buffers_to_clipboard, { desc = "Copy all buffers to clipboard" })

local function swap_path_line()
  -- Path mappings (without requiring the exact path with trailing slash)
  local paths = {
    ["/home/safi/safihasanfaraz%-share"] = "/home/hassan/sharefiles-text",
    ["/home/hassan/sharefiles%-text"] = "/home/safi/safihasanfaraz-share",
  }

  -- Get the current line
  local line = vim.api.nvim_get_current_line()
  local new_line = line

  -- Try each path mapping
  for from_path, to_path in pairs(paths) do
    if line:find(from_path) then
      new_line = line:gsub(from_path, to_path)
      break
    end
  end

  -- Update the current line if a replacement was made
  if new_line ~= line then
    vim.api.nvim_set_current_line(new_line)
    print("Path swapped!")
  else
    print("No matching path found on this line.")
  end
end

local function swap_paths_file()
  -- Path mappings (without requiring the exact path with trailing slash)
  local paths = {
    ["/home/safi/safihasanfaraz%-share"] = "/home/hassan/sharefiles-text",
    ["/home/hassan/sharefiles%-text"] = "/home/safi/safihasanfaraz-share",
  }

  -- Get all lines in the buffer
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local changes_made = false

  for i, line in ipairs(lines) do
    local new_line = line

    -- Try each path mapping on this line
    for from_path, to_path in pairs(paths) do
      if line:find(from_path) then
        new_line = line:gsub(from_path, to_path)
        changes_made = true
        break
      end
    end

    -- Update the line if changes were made
    if new_line ~= line then
      lines[i] = new_line
    end
  end

  -- Update the buffer with modified lines
  if changes_made then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    print("All paths in file swapped!")
  else
    print("No matching paths found in file.")
  end
end

-- Add your keymaps here
vim.keymap.set("n", "<leader>an", swap_path_line, { noremap = true, desc = "Swap file path on current line" })
vim.keymap.set("n", "<leader>aN", swap_paths_file, { noremap = true, desc = "Swap all file paths in the entire file" })



vim.keymap.set("n", "<leader>or", function()
  require("overseer").run_template({ name = "Run current file" })
end, { desc = "Run Python file with Overseer" })




vim.api.nvim_create_user_command("SmartMdComment", function()
  local line = vim.fn.getline(".")
  -- Check if line starts with <!-- and ends with -->
  if not line:match("^%s*<!%-%-") and not line:match("%-%->%s*$") then
    -- Wrap the line in <!-- `...` -->
    local commented = string.format("<!-- `%s` -->", vim.trim(line))
    vim.fn.setline(".", commented)
  end
end, {})


vim.keymap.set("n", "<leader>sc", ":SmartMdComment<CR>", { desc = "Smart Comment Markdown Line" })


-- dynamic gf
local api = vim.api
local fn = vim.fn
local lsp = vim.lsp
local util = vim.lsp.util
local notify = vim.notify
-- Resolve a single VAR name to its string value
local function resolve_var(var)
  -- 1) scan upwards in this buffer
  local cur = api.nvim_win_get_cursor(0)[1]
  local lines = api.nvim_buf_get_lines(0, 0, cur, false)
  for i = #lines, 1, -1 do
    local l = lines[i]
    local dbl = l:match(var .. '%s*=%s*"([^"]+)"')
    local sng = l:match(var .. "%s*=%s*'([^']+)'")
    if dbl or sng then
      return dbl or sng
    end
  end
  -- 2) fallback to LSP definition
  local clients = lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return nil, "no LSP client"
  end
  local client = clients[1]
  local enc = client.offset_encoding or "utf-16"
  local params = util.make_position_params(nil, enc)
  local results = lsp.buf_request_sync(0, "textDocument/definition", params, 500)
  if not results then
    return nil, "no LSP definition"
  end
  for _, resp in pairs(results) do
    for _, loc in ipairs(resp.result or {}) do
      local bufnr = fn.bufnr(fn.uri_to_fname(loc.uri))
      api.nvim_buf_load(bufnr)
      local line = api.nvim_buf_get_lines(bufnr, loc.range.start.line, loc.range.start.line + 1, false)[1] or ""
      local dbl = line:match('"(.-)"')
      local sng = line:match("'(.-)'")
      if dbl or sng then
        return dbl or sng
      end
    end
  end
  return nil, "no string literal found"
end
-- main function
local function dynamic_gf()
  -- 1) get the full WORD under cursor
  local target = fn.expand("<cWORD>")
  -- 2) find all {VARS}
  local any = false
  local real = target:gsub("{(.-)}", function(var)
    any = true
    local val, err = resolve_var(var)
    if not val then
      notify(("Could not resolve {%s}: %s"):format(var, err), vim.log.levels.WARN)
      error("abort gf") -- stop the gsub and skip opening
    end
    return val
  end)
  if not any then
    -- no braces → plain gf
    return vim.cmd("normal! gf")
  end
  -- 3) open the resolved path
  vim.cmd("edit " .. fn.fnameescape(real))
end
-- Map it: keep plain 'gf' untouched
vim.keymap.set("n", "gF", function()
  -- protect against our abort
  local ok, _ = pcall(dynamic_gf)
  if not ok then
    return
  end
end, {
  noremap = true,
  silent = true,
  desc = "gf that expands {VARS} via nearest assignment or LSP",
})



vim.keymap.set("n", "<F2>", function()
  local filepath = vim.fn.expand("%:p")
  vim.fn.setreg("+", filepath)
  vim.notify("Copied file path: " .. filepath)
end, { desc = "Copy full file path to clipboard" })


vim.api.nvim_set_keymap("n", "<leader>gdw", ":tab Git diff --word-diff<CR>",
  { noremap = true, silent = true })
