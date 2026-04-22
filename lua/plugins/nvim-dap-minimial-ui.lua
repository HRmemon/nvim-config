-- if true then return {} end
return {
  "igorlfs/nvim-dap-view",
  opts = {
    winbar = {
      show = true,
      sections = { "scopes", "watches", "breakpoints", "threads", "repl" },
      default_section = "scopes",
    },
    windows = {
      size = 0.25,
      position = "below",
      terminal = { size = 0.5, position = "left", hide = { "go", "python" } },
    },
    auto_toggle = true, -- open/close with sessions
  },
  keys = {
    { "<leader>dm", "<cmd>DapViewToggle<cr>", desc = "Toggle Dap View" },
  },
  dependencies = {
    "jay-babu/mason-nvim-dap.nvim",
    -- "leoluz/nvim-dap-go",
    "mfussenegger/nvim-dap-python",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
  },
}
