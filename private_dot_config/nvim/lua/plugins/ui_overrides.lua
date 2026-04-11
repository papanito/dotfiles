return {
  {
    -- Snacks Picker: Include hidden files in finds/grep
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = { hidden = true },
          grep = { hidden = true },
          explorer = { hidden = true }, -- Snacks file explorer sidebar
        },
      },
    },
  },
}
