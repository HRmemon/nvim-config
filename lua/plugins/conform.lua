return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "Format Document/Selection",
    },
  },
  -- This will provide type hinting with LuaLS
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    -- Define your formatters
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" },
      -- javascript = { "prettierd", stop_after_first = true },
      javascript = { "biome" },
      typescript = { "biome" },
      javascriptreact = { "biome" },
      typescriptreact = { "biome" },
      json = { "biome" },
      html = { "prettier" },
      css = { "prettier" },
      yaml = { "prettier" },
      -- shell
      sh = { "shfmt" },
    },
    -- Set default options
    default_format_opts = {
      lsp_format = "fallback",
    },
    -- Set up format-on-save (disabled by default)
    -- Auto-enabled if .autoformat or prettier config exists in project root
    format_on_save = function(bufnr)
      local root = vim.fs.root(bufnr, { ".git", "package.json", "pyproject.toml" })
      if not root then
        return nil
      end

      -- Check for .autoformat marker
      if vim.uv.fs_stat(root .. "/.autoformat") then
        return { timeout_ms = 500, lsp_format = "fallback" }
      end

      -- Check for prettier config files
      local prettier_configs = {
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.js",
        ".prettierrc.cjs",
        ".prettierrc.yaml",
        ".prettierrc.yml",
        "prettier.config.js",
        "prettier.config.cjs",
      }
      for _, config in ipairs(prettier_configs) do
        if vim.uv.fs_stat(root .. "/" .. config) then
          return { timeout_ms = 500, lsp_format = "fallback" }
        end
      end

      return nil
    end,
    -- Customize formatters
    formatters = {
      biome = {
        command = "biome",
        args = { "format", "--stdin-file-path", "$FILENAME" },
      },
    },
  },
}
