-- File: ~/.config/nvim/lua/plugins/colorscheme.lua

local M = {
  -- Core backgrounds
  background = "#1d2021", -- Darker background for better contrast
  inactive_bg = "#282828", -- Increased contrast for non-focused windows
  selection_bg = "#504945", -- Higher contrast for visual selection

  -- Core text colors
  text = "#fbf1c7", -- Brighter main text
  comment = "#a89984", -- Lighter comments

  -- Syntax highlighting
  blue = "#83a598", -- Methods, UI elements
  green_light = "#8ec07c", -- Strings, success indicators
  green = "#b8bb26", -- Types, namespaces
  keyword_color = "#d4728d", -- Keywords (if, def, for)
  function_color = "#83a598", -- Functions
  red = "#fb4934", -- Errors, important elements
  yellow = "#fabd2f", -- Warnings, special variables
  purple = "#d3869b", -- Special keywords, decorators
  aqua = "#8ec07c", -- Booleans, special elements

  -- UI Elements
  diff_add = "#b8bb26",
  diff_change = "#fabd2f",
  diff_delete = "#fb4934",
  ui_border = "#665c54",

  -- Grayscale UI
  g_4 = "#bdae93", -- Light text elements
  g_8 = "#504945", -- Match parentheses background
  g_11 = "#504945", -- Visual selection background
  g_12 = "#3c3836", -- Cursor line background

  -- Search and selection highlights
  search_highlight_bg = "#fabd2f",
  search_highlight_fg = "#1d2021",
  current_selection_bg = "#fe8019",
  current_selection_fg = "#1d2021",
}

return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000, -- Make sure to load this before other plugins
    lazy = false, -- Load on startup
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
        transparent_mode = false,
        overrides = {
          -- Base editor elements
          Normal = { bg = M.background, fg = M.text },
          NormalNC = { bg = M.inactive_bg },
          Comment = { fg = M.comment, italic = true },

          -- Search and selection highlighting
          Search = { bg = M.search_highlight_bg, fg = M.search_highlight_fg, bold = true },
          IncSearch = { bg = M.current_selection_bg, fg = M.current_selection_fg, bold = true },
          CursorLine = { bg = M.g_12 },
          Visual = { bg = M.g_11 },
          MatchParen = { bg = M.g_8 },

          -- FZF-Lua specific highlights
          FzfLuaPreviewNormal = { bg = M.background },
          FzfLuaPreviewBorder = { fg = M.ui_border },
          FzfLuaPreviewTitle = { fg = M.yellow, bold = true },
          FzfLuaNormal = { bg = M.background },
          FzfLuaBorder = { fg = M.ui_border },
          FzfLuaTitle = { fg = M.yellow, bold = true },
          FzfLuaCursor = { bg = M.current_selection_bg, fg = M.current_selection_fg },
          FzfLuaSelected = { bg = M.search_highlight_bg, fg = M.search_highlight_fg },

          -- Syntax highlighting (using treesitter scopes)
          ["@function"] = { fg = M.function_color },
          ["@function.call"] = { fg = M.function_color },
          ["@method"] = { fg = M.blue },
          ["@variable"] = { fg = M.text },
          ["@parameter"] = { fg = M.aqua, italic = true },
          ["@keyword"] = { fg = M.keyword_color },
          ["@type"] = { fg = M.green },
          ["@string"] = { fg = M.green_light },
          ["@number"] = { fg = M.purple },
          ["@boolean"] = { fg = M.aqua },
          ["@operator"] = { fg = M.g_4 },
          ["@exception"] = { fg = M.red },

          -- Diagnostics
          DiagnosticError = { fg = M.red },
          DiagnosticWarn = { fg = M.yellow },
          DiagnosticInfo = { fg = M.blue },
          DiagnosticHint = { fg = M.green_light },

          -- Git Integration
          GitSignsAdd = { fg = M.diff_add },
          GitSignsDelete = { fg = M.diff_delete },
          GitSignsChange = { fg = M.diff_change },

          -- Plugin Support
          WhichKeyFloat = { bg = M.background },
        },
      })
      -- Set the colorscheme after setup
      vim.cmd.colorscheme("gruvbox")
    end,
  },
}
