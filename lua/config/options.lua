-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.snacks_animate = false

-- vim.opt.clipboard = ""
-- Add any additional options here
-- vim.opt.formatoptions:remove({ "c", "r", "o" })

-- set diagnostic level to error
-- vim.diagnostic.config({
--   virtual_text = {
--     severity = vim.diagnostic.severity.ERROR,
--   },
--   signs = {
--     severity = vim.diagnostic.severity.ERROR,
--   },
--   underline = {
--     severity = vim.diagnostic.severity.ERROR,
--   },
--   severity_sort = true,
-- })

vim.g.clipboard = {
  name = "wl-clipboard",
  copy = {
    ["+"] = "wl-copy",
    ["*"] = "wl-copy --primary",
  },
  paste = {
    ["+"] = "wl-paste",
    ["*"] = "wl-paste --primary",
  },
  cache_enabled = 1,
}


vim.opt.diffopt:append({
  "iwhite",             -- ignore whitespace
  "internal",           -- use internal diff
  "algorithm:patience", -- better for code diffs
  "linematch:60",       -- attempts word diffing within changed lines
})
