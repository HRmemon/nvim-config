return {
  -- Mason for managing external tools
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
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
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "lua_ls",
        -- "emmylua_ls",
        -- "stylua",
        "pyright",
        "ts_ls",
        "prismals",
        "copilot",
        "marksman",
        "terraformls",
        "bashls",
        "jsonls",

        -- install but don't enable by default
        "ruff",
        "biome",
      },
      automatic_installation = true,
      automatic_enable = {
        exclude = { "ruff", "biome", "marksman" }
      },
    },
  },
}
