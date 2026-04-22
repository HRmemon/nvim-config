local notes_path = vim.fn.expand("~/notes")

return {
  -- obsidian.nvim (community fork)
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- use latest release (recommended)
    -- only load for files in ~/notes/*.md
    event = {
      "BufReadPre " .. notes_path .. "/*.md",
      "BufNewFile " .. notes_path .. "/*.md",
    },
    dependencies = {
      -- required
      "nvim-lua/plenary.nvim",
      -- If using blink.cmp, ensure it's a dependency
      {
        "saghen/blink.cmp",
        dependencies = {
          { "saghen/blink.compat", branch = "main" },
        },
      },
    },
    opts = {
      legacy_commands = false,
      -- point the plugin at your single workspace (~/notes)
      workspaces = {
        {
          name = "notes",
          path = notes_path,
        },
      },
      completion = {
        nvim_cmp = false, -- Disable nvim-cmp if you're using blink.cmp
        blink = true,     -- Enable blink.cmp
        min_chars = 1,    -- Minimum characters to trigger completion
      },
      -- other obsidian.nvim options may be added here if you want
    },
  }
}
