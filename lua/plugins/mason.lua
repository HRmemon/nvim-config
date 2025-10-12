return {
  -- Mason for managing external tools
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- Mason-LSPConfig integration
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "pyright",
        "ts_ls",
        "prismals",
        "copilot",

        -- install but don't enable by default
        "ruff",
        "biome",
      },
      automatic_installation = true,
      automatic_enable = {
        exclude = { "ruff", "biome" },
      },
    },
  },
}
