-- if true then return {} end
return {
  "theHamsta/nvim-dap-virtual-text",
  event = "VeryLazy",
  config = true,
  dependencies = {
    "mfussenegger/nvim-dap",
  },
}
