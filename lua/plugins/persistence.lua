return {
  "folke/persistence.nvim",
  event = "VeryLazy",                            -- start only when an actual file was opened
  opts = {
    dir = vim.fn.stdpath("state") .. "/sessions/", -- where sessions are saved
    need = 1,                                    -- minimum number of buffers to save (set 0 to always save)
    branch = true,                               -- use git branch name in session filename
  },
  init = function()
    -- Load session on startup if no files specified
    if vim.fn.argc() == 0 then
      vim.schedule(function()
        require("persistence").load()
      end)
    end
  end,
}
