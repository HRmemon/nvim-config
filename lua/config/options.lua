vim.opt.diffopt:append({
  "iwhite",             -- ignore whitespace
  "internal",           -- use internal diff
  "algorithm:patience", -- better for code diffs
  "linematch:60",       -- attempts word diffing within changed lines
})


local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.clipboard = "unnamedplus"

opt.confirm = true

opt.scrolloff = 0
opt.wrap = false -- optional, turns off line wrapping
opt.sidescrolloff = 0
opt.linebreak = false
opt.jumpoptions = "view"

opt.splitbelow = true
opt.splitright = true

opt.undofile = true
opt.undolevels = 10000
opt.termguicolors = true -- True color support

opt.tabstop = 2 -- visual width of tabs
opt.shiftwidth = 2 -- indentation width when using >> or <<
opt.softtabstop = 2 -- how many spaces a tab feels like when editing
opt.expandtab = true -- convert tabs to spaces
vim.o.ignorecase = true -- case-insensitive by default
vim.o.smartcase = true -- if uppercase used, makes it case-sensitive
-- nocursorline
opt.cursorline = false -- highlight the line with the cursor
-- Enable smart, minimal diffs in Neovim
vim.o.diffopt = "internal,filler,closeoff,indent-heuristic,linematch:60,algorithm:histogram"
opt.wildmenu = true
opt.wildmode = { "longest:full", "full" }
opt.path:append("**")
opt.wildignore:append({
	"**/node_modules/**",
	"**/.git/**",
	"**/dist/**",
	"**/build/**",
	"**/.next/**",
	"**/coverage/**",
})
