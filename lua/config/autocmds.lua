-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.diagnostic.disable(0) -- no table, just a number
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:remove({ "o", "r" })
  end,
})

-- ===== Folke's default
-- This file is automatically loaded by lazyvim.config.init.

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Define your custom highlight group
vim.api.nvim_set_hl(0, "WordUnderCursor", { bg = "#494542" }) -- pick your color

-- Highlight word under cursor with it
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  callback = function()
    local word = vim.fn.expand("<cword>")
    if #word >= 1 then
      local escaped = vim.fn.escape(word, "\\/.*$^~[]") -- escape regex specials
      -- local escaped = print(vim.fn.escape("*******/", "\\/.*$^~[]")) -- escape regex specials
      vim.fn.matchadd("WordUnderCursor", "\\V\\<" .. escaped .. "\\>")
    end
  end,
})

vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function()
    vim.fn.clearmatches()
  end,
})



vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("kickstart-lsp-attach-ruff", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "ruff" then
      -- Disable hover in favor of Pyright's richer hover information
      client.server_capabilities.hoverProvider = false
    end
  end,
})


vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local bufnr = ev.buf
    local opts = { buffer = bufnr, noremap = true, silent = true }

    -- LSP keymaps
    vim.keymap.set("n", "gd", function()
      require("fzf-lua").lsp_definitions()
    end, opts)

    vim.keymap.set("n", "gr", function()
      require("fzf-lua").lsp_references()
    end, opts)

    -- Additional LSP keymaps using fzf-lua
    vim.keymap.set("n", "gD", function()
      require("fzf-lua").lsp_declarations()
    end, vim.tbl_extend("force", opts, { desc = "Go to Declaration" }))

    vim.keymap.set("n", "gy", function()
      require("fzf-lua").lsp_typedefs()
    end, vim.tbl_extend("force", opts, { desc = "Go to Type Definition" }))

    vim.keymap.set("n", "gi", function()
      require("fzf-lua").lsp_implementations()
    end, vim.tbl_extend("force", opts, { desc = "Go to Implementation" }))

    vim.keymap.set("n", "<leader>fs", function()
      require("fzf-lua").lsp_document_symbols()
    end, vim.tbl_extend("force", opts, { desc = "Document Symbols" }))

    vim.keymap.set("n", "<leader>fS", function()
      require("fzf-lua").lsp_workspace_symbols()
    end, vim.tbl_extend("force", opts, { desc = "Workspace Symbols" }))

    vim.keymap.set("n", "<leader>fi", function()
      require("fzf-lua").lsp_incoming_calls()
    end, vim.tbl_extend("force", opts, { desc = "Incoming Calls" }))

    vim.keymap.set("n", "<leader>fo", function()
      require("fzf-lua").lsp_outgoing_calls()
    end, vim.tbl_extend("force", opts, { desc = "Outgoing Calls" }))

    -- Code actions using fzf-lua
    vim.keymap.set({ "n", "v" }, "<leader>ca", function()
      require("fzf-lua").lsp_code_actions()
    end, vim.tbl_extend("force", opts, { desc = "Code Actions" }))

    -- Other LSP functionality (still using built-in as these don't benefit much from fzf)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
    -- vim.keymap.set(
    -- 	"n",
    -- 	"<C-k>",
    -- 	vim.lsp.buf.signature_help,
    -- 	vim.tbl_extend("force", opts, { desc = "Signature Help" })
    -- )
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))

    -- Workspace management
    vim.keymap.set(
      "n",
      "<leader>wa",
      vim.lsp.buf.add_workspace_folder,
      vim.tbl_extend("force", opts, { desc = "Add Workspace Folder" })
    )
    vim.keymap.set(
      "n",
      "<leader>wr",
      vim.lsp.buf.remove_workspace_folder,
      vim.tbl_extend("force", opts, { desc = "Remove Workspace Folder" })
    )
    vim.keymap.set("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, vim.tbl_extend("force", opts, { desc = "List Workspace Folders" }))

    -- Enable inlay hints if supported (Neovim 0.10+)
    if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
      vim.keymap.set("n", "<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, vim.tbl_extend("force", opts, { desc = "Toggle Inlay Hints" }))
    end
  end,
})
