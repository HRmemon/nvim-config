return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lspconfig = require("lspconfig")

    vim.lsp.config["lua_ls"] = {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    }

    -- Pyright optimization for faster startup
    vim.lsp.config["pyright"] = {
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            typeCheckingMode = "basic", -- "off", "basic", "standard", "strict"
            diagnosticMode = "openFilesOnly", -- Only analyze open files, not entire workspace
          },
        },
      },
    }

    -- vim.lsp.config["marksman"] = {
    --   filetypes = { "markdown", "mdx" },
    --   settings = {
    --     ["marksman"] = {
    --       -- Disable project-wide file watching (major memory saver)
    --       workspace = {
    --         watch = false,
    --         exclude = { "node_modules", "build", "dist", ".git", ".cache" },
    --       },
    --     },
    --   },
    -- }


    -- General diagnostic settings
    vim.diagnostic.config({
      virtual_lines = false,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })
  end,
}
