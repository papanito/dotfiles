return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp", -- Optional: For using slash commands and variables in the chat buffer
    "nvim-telescope/telescope.nvim", -- Optional: For using slash commands with variables
    "stevearc/dressing.nvim", -- Optional: Improves the default Neovim UI
  },
  keys = {
    { "<leader>cc", "<cmd>CodeCompanionChat Toggle<CR>", mode = { "n", "v" }, desc = "CodeCompanion: Toggle Chat" },
    { "<leader>ci", "<cmd>CodeCompanion<CR>", mode = { "n", "v" }, desc = "CodeCompanion: Inline Prompt" },
    { "<leader>ca", "<cmd>CodeCompanionActions<CR>", mode = { "n", "v" }, desc = "CodeCompanion: Actions" },
    {
      "<leader>cs",
      function()
        -- Explicitly list the keys you defined in the 'adapters' block below
        local my_adapters = {
          -- 1. Your Custom Defined Adapters
          "gemini_flash",
          "gemini_pro",
          "gemini_flash_31",
          "gemini_pro_31",
          "claude",
          -- 2. Standard Defaults (if you want them as fallbacks)
          "anthropic",
          "gemini",
          "openai",
          "ollama",
        }
        vim.ui.select(my_adapters, {
          prompt = "Select CodeCompanion Adapter:",
          format_item = function(item)
            return item:gsub("_", " "):gsub("^%l", string.upper) -- Prettify names
          end,
        }, function(choice)
          if choice then
            -- Set the adapter for the current chat session
            vim.cmd("CodeCompanionChat " .. choice)
            vim.notify("Switched to " .. choice, vim.log.levels.INFO)
          end
        end)
      end,
      mode = "n",
      desc = "CodeCompanion: Switch Adapter",
    },
  },
  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = { adapter = "gemini_flash" }, -- Default for chat
        inline = { adapter = "gemini_flash" }, -- Default for inline edits
        agent = { adapter = "gemini_flash" }, -- Default for inline edits
      },
      adapters = {
        -- Use 2.5 Flash: It's the most stable "actually free" model right now
        gemini_flash = function()
          return require("codecompanion.adapters").extend("gemini", {
            name = "Gemini Flash (Stable Free)",
            schema = {
              model = { default = "gemini-2.5-flash" }, -- Avoid '-preview' strings
            },
          })
        end,
        gemini_pro = function()
          return require("codecompanion.adapters").extend("gemini", {
            name = "Gemini Pro (Rate Limited)",
            schema = {
              model = { default = "gemini-2.5-pro" },
            },
          })
        end,
        -- Gemini 3.1 Flash (The Best "Free" Default)
        gemini_flash_31 = function()
          return require("codecompanion.adapters").extend("gemini", {
            name = "Gemini 3.1 Flash (Free)",
            schema = {
              model = { default = "gemini-3.1-flash-preview" },
            },
          })
        end,
        -- Gemini 3.1 Pro (Free but slower/lower limits)
        gemini_pro_31 = function()
          return require("codecompanion.adapters").extend("gemini", {
            name = "Gemini 3.1 Pro (Free)",
            schema = {
              model = { default = "gemini-3.1-pro-preview" },
            },
          })
        end,
        --  Claude 4.6 Sonnet (The Coding King - Paid)
        claude = function()
          return require("codecompanion.adapters").extend("anthropic", {
            name = "Claude 4.6 Sonnet",
            schema = {
              model = { default = "claude-4-6-sonnet" },
            },
          })
        end,
      },
    })
  end,
}
