return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          local ok, fzf_lua = pcall(require, "fzf-lua")
          if not ok then
            return function()
              vim.notify("FzfLua not available", vim.log.levels.ERROR)
            end
          end
          local ok2, fn = pcall(function()
            return fzf_lua[cmd]
          end)
          if ok2 then
            return function()
              fn(opts or {})
            end
          else
            return function()
              vim.notify("Invalid fzf-lua command: " .. cmd, vim.log.levels.ERROR)
            end
          end
        end,
        header = [[
██╗   ██╗ ██████╗██╗  ██╗██╗██╗  ██╗ █████╗
██║   ██║██╔════╝██║  ██║██║██║  ██║██╔══██╗
██║   ██║██║     ███████║██║███████║███████║
██║   ██║██║     ██╔══██║██║██╔══██║██╔══██║
╚██████╔╝╚██████╗██║  ██║██║██║  ██║██║  ██║
 ╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝
        ]],
        keys = {
          {
            icon = " ",
            key = "f",
            desc = "Smart Open",
            action = function()
              -- Load fzf-lua frecency and call smart open with proper cwd
              local git_utils = require("utils.git")
              require("fzf-lua-frecency").frecency({
                cwd = git_utils.get_git_root(),
                cwd_only = true,
                all_files = true,
                previewer = false,
              })
            end,
          },
          {
            icon = " ",
            key = "a",
            desc = "Find All Files",
            action = function()
              -- Load fzf-lua and call files with proper cwd
              local git_utils = require("utils.git")
              require("fzf-lua").files({
                cwd = git_utils.get_git_root(),
                fd_opts = [[--color=never --hidden --type f --type l --exclude .git --no-ignore]],
              })
            end,
          },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          {
            icon = " ",
            key = "g",
            desc = "Find Text",
            action = function()
              -- Load fzf-lua and call live_grep
              require("fzf-lua").live_grep({ exec_empty_query = true })
            end,
          },
          {
            icon = "  ",
            key = "r",
            desc = "Recent Files",
            action = function()
              -- Load fzf-lua and call oldfiles
              require("fzf-lua").oldfiles()
            end,
          },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = function()
              -- Load fzf-lua and find config files
              require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
            end,
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
    lazygit = {
      enabled = true,
    },
    bigfile = {
      enabled = true,
      opts = {
        notify = true,            -- show notification when big file detected
        size = 1.5 * 1024 * 1024, -- 1.5MB
        line_length = 1000,       -- average line length (useful for minified files)
        -- Enable or disable features when big file detected
        ---@param ctx {buf: integer, ft:string}
        setup = function(ctx)
          if vim.fn.exists(":NoMatchParen") ~= 0 then
            vim.cmd([[NoMatchParen]])
          end
          Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
          vim.b.minianimate_disable = true
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(ctx.buf) then
              vim.bo[ctx.buf].syntax = ctx.ft
            end
          end)
        end,
      },
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
