return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = [[
██╗   ██╗ ██████╗██╗  ██╗██╗██╗  ██╗ █████╗
██║   ██║██╔════╝██║  ██║██║██║  ██║██╔══██╗
██║   ██║██║     ███████║██║███████║███████║
██║   ██║██║     ██╔══██║██║██╔══██║██╔══██║
╚██████╔╝╚██████╗██║  ██║██║██║  ██║██║  ██║
 ╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝
        ]],
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
    lazygit = {
      enabled = true,
    },
    bigfile = {
      enabled = true,
      notify = true,
      size = 1 * 1024 * 1024, -- 1MB
      line_length = 1000,

      ---@param ctx {buf: integer, ft: string}
      setup = function(ctx)
        -- Disable matchparen
        if vim.fn.exists(":NoMatchParen") ~= 0 then
          vim.cmd("NoMatchParen")
        end

        -- Disable syntax and filetype detection
        vim.bo[ctx.buf].syntax = ""
        vim.bo[ctx.buf].filetype = ""

        -- Disable LSP for this buffer
        vim.b[ctx.buf].lsp_disabled = true

        -- Disable window options
        Snacks.util.wo(0, {
          foldmethod = "manual",
          statuscolumn = "",
          conceallevel = 0,
          spell = false,
          list = false,
          cursorline = false,
          cursorcolumn = false,
          relativenumber = false,
          signcolumn = "no",
        })

        -- Disable buffer-local features
        vim.bo[ctx.buf].swapfile = false
        vim.bo[ctx.buf].undofile = false

        vim.b[ctx.buf].minianimate_disable = true

        -- Disable treesitter
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ctx.buf) then
            pcall(vim.treesitter.stop, ctx.buf)
          end
        end)

        -- Detach LSP clients
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ctx.buf) then
            local clients = vim.lsp.get_clients({ bufnr = ctx.buf })
            for _, client in ipairs(clients) do
              vim.lsp.buf_detach_client(ctx.buf, client.id)
            end
          end
        end)
      end,
    },
    statuscolumn = {
      enabled = true,
    },
    bufdelete = {
      enabled = true,
    },
    terminal = {
      enabled = true,
    },
    picker = {
      enabled = true,
    },
  },
}
