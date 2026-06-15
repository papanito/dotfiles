return {
  "alex35mil/pi.nvim",

  -- Optional: required only for `:PiPasteImage` (clipboard image paste).
  dependencies = { "HakonHarnes/img-clip.nvim" },

  -- if you're fine with defaults:
  config = function()
    -- 1. Setup the plugin with default settings
    require("pi").setup({
      bin = vim.fn.exepath("omp"),
    })

    local pi = require("pi")

    -- ==========================================
    -- 2. Global Mappings
    -- (Open / toggle / resume from anywhere)
    -- ==========================================
    vim.keymap.set({ "n", "v" }, "<Leader>pp", function()
      vim.cmd("Pi layout=side")
    end, { desc = "Pi side" })
    vim.keymap.set({ "n", "v" }, "<Leader>pf", function()
      vim.cmd("Pi layout=float")
    end, { desc = "Pi float" })
    vim.keymap.set({ "n", "v" }, "<Leader>pl", "<Cmd>PiToggleLayout<CR>", { desc = "Pi toggle layout" })
    vim.keymap.set({ "n", "v" }, "<Leader>pc", "<Cmd>PiContinue<CR>", { desc = "Pi continue last session" })
    vim.keymap.set({ "n", "v" }, "<Leader>pr", "<Cmd>PiResume<CR>", { desc = "Pi resume past session" })
    vim.keymap.set({ "n", "v" }, "<Leader>pM", "<Cmd>PiSendMention<CR>", { desc = "Pi mention file/selection" })
    vim.keymap.set({ "n", "v" }, "<Leader>pm", "<Cmd>PiSelectModelAll<CR>", { desc = "Pi select model" })
    vim.keymap.set({ "n", "v" }, "<Leader>pa", "<Cmd>PiAttention<CR>", { desc = "Pi open next attention request" })

    -- ==========================================
    -- 3. Buffer-local Mappings (inside π windows)
    -- ==========================================
    local group = vim.api.nvim_create_augroup("pi-keymaps", { clear = true })

    local function map(buf, key, action, modes)
      vim.keymap.set(modes or { "n", "i", "v" }, key, action, { buffer = buf })
    end

    -- Shared across all π windows
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = { "pi-chat-history", "pi-chat-prompt", "pi-chat-attachments" },
      callback = function(event)
        map(event.buf, "<C-q>", "<Cmd>PiToggleChat<CR>")
        map(event.buf, "<M-c>", "<Cmd>PiAbort<CR>")
      end,
    })

    -- History window: jump to prompt
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "pi-chat-history",
      callback = function(event)
        -- Replace <S-Down> if you use custom window navigation keys
        map(event.buf, "<S-Down>", pi.focus_chat_prompt)
      end,
    })

    -- Prompt window: navigation, scrolling, model & thinking, sessions, attachments
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "pi-chat-prompt",
      callback = function(event)
        -- Focus navigation (Replace <S-Up>/<S-Down> with your own window shortcuts if desired)
        map(event.buf, "<S-Up>", pi.focus_chat_history)
        map(event.buf, "<S-Down>", pi.focus_chat_attachments)

        -- Scroll history from the prompt
        map(event.buf, "<C-Up>", function()
          pi.scroll_chat_history("up", 2)
        end)
        map(event.buf, "<C-Down>", function()
          pi.scroll_chat_history("down", 2)
        end)

        -- Model & thinking
        map(event.buf, "<M-m>", pi.cycle_model)
        map(event.buf, "<M-M>", pi.select_model_all)
        map(event.buf, "<M-t>", pi.cycle_thinking_level)
        map(event.buf, "<M-T>", pi.select_thinking_level)

        -- Sessions & context
        map(event.buf, "<M-n>", pi.new_session)
        map(event.buf, "<M-x>", pi.compact)

        -- Attachments
        map(event.buf, "<C-v>", pi.paste_image)
      end,
    })

    -- Attachments window: jump back to prompt, paste image
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "pi-chat-attachments",
      callback = function(event)
        map(event.buf, "<S-Up>", pi.focus_chat_prompt)
        map(event.buf, "<C-v>", pi.paste_image)
      end,
    })
  end,
}
