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
          "openrouter",
          "gemini_flash",
          "gemini_pro",
          "gemini_flash_31",
          "gemini_pro_31",
          "claude",
          -- 2. Standard Defaults
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
        chat = { adapter = "openrouter" }, -- Default for chat
        inline = { adapter = "openrouter" }, -- Default for inline edits
        agent = { adapter = "openrouter" }, -- Default for agents
      },
      adapters = {
        http = {
          opts = {
            show_presets = true,
          },
          openrouter = function()
            return require("codecompanion.adapters").extend("openai", {
              env = {
                api_key = "OPENROUTER_API_KEY",
              },
              url = "https://openrouter.ai/api/v1/chat/completions",
              headers = {
                ["HTTP-Referer"] = "https://github.com/olimorris/codecompanion.nvim",
                ["X-OpenRouter-Title"] = "CodeCompanion",
              },
              schema = {
                model = {
                  default = "anthropic/claude-sonnet-4.6",
                },
              },
            })
          end,
          -- Use 2.5 Flash: It's the most stable "actually free" model right now
          gemini_flash = function()
            return require("codecompanion.adapters").extend("gemini", {
              schema = {
                model = { default = "gemini-2.5-flash" },
              },
            })
          end,
          gemini_pro = function()
            return require("codecompanion.adapters").extend("gemini", {
              schema = {
                model = { default = "gemini-2.5-pro" },
              },
            })
          end,
          -- Gemini 3.1 Flash (The Best "Free" Default)
          gemini_flash_31 = function()
            return require("codecompanion.adapters").extend("gemini", {
              schema = {
                model = { default = "gemini-3.1-flash-preview" },
              },
            })
          end,
          -- Gemini 3.1 Pro (Free but slower/lower limits)
          gemini_pro_31 = function()
            return require("codecompanion.adapters").extend("gemini", {
              schema = {
                model = { default = "gemini-3.1-pro-preview" },
              },
            })
          end,
          --  Claude 4.6 Sonnet (The Coding King - Paid)
          claude = function()
            return require("codecompanion.adapters").extend("anthropic", {
              schema = {
                model = { default = "claude-sonnet-4.6" },
              },
            })
          end,
        },
      },
    })
  end,
}
