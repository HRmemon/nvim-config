return {
  {
    "vhyrro/luarocks.nvim",
    event = "VeryLazy",
    priority = 1000,
    opts = {
      rocks = { "magick" }, -- REQUIRED for image.nvim
    },
  },

  {
    "3rd/image.nvim",
    ft = { "markdown" }, -- only load for markdown
    event = "BufReadPre",
    dependencies = { "vhyrro/luarocks.nvim" },
    config = function()
      require("image").setup({
        backend = "kitty", -- THIS is the whole point
        max_width = 100,
        max_height = 12,
        max_height_window_percentage = 50,

        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = true,
            only_render_image_at_cursor = false,
          },
        },

        hijack_file_patterns = {
          "*.png",
          "*.jpg",
          "*.jpeg",
          "*.gif",
          "*.webp",
        },
      })
    end,
  },
}
