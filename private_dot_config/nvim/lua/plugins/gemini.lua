return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = { adapter = "gemini" },
        inline = { adapter = "gemini" },
        agent = { adapter = "gemini" },
      },
    })
  end,
}

