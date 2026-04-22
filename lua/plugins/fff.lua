return {
  {
    "dmtrKovalenko/fff.nvim",
    build = function(plugin)
      local lua_path = table.concat({
        plugin.dir .. "/lua/?.lua",
        plugin.dir .. "/lua/?/init.lua",
      }, ";")
      package.path = lua_path .. ";" .. package.path
      require("fff.download").download_or_build_binary()
    end,
    lazy = false,
    opts = {
      lazy_sync = true,
      prompt = "   ",
      title = "FFF",
      layout = {
        width = 0.85,
        height = 0.8,
        preview_position = "right",
        prompt_position = "bottom",
      },
      preview = {
        enabled = true,
        wrap_lines = false,
      },
      frecency = {
        enabled = true,
      },
      history = {
        enabled = true,
      },
      logging = {
        enabled = true,
        log_level = "info",
      },
      debug = {
        enabled = false,
        show_scores = false,
      },
      grep = {
        modes = { "plain", "regex", "fuzzy" },
      },
    },
  },
}
