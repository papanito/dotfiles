return {
  "alex35mil/pi.nvim",
  -- Optional: required only for `:PiPasteImage` (clipboard image paste).
  dependencies = { "HakonHarnes/img-clip.nvim" },
  -- if you're fine with defaults:
  config = function()
    local function normalize_omp_commands(commands)
      local result = {}
      for _, command in ipairs(commands or {}) do
        local cmd = vim.deepcopy(command)
        if cmd.source == "file" or cmd.source == "custom" or cmd.source == "mcp_prompt" then
          cmd.source = "prompt"
        elseif cmd.source == "builtin" then
          cmd.source = "extension"
        end
        result[#result + 1] = cmd
      end
      return result
    end
    local omp_command_map = {
      get_commands = "get_available_commands",
      get_available_models = "get_available_models",
      set_model = "set_model",
      cycle_model = "cycle_model",
      get_state = "get_state",
    }

    -- Strip ANSI escape codes from text (omp command_output often has them).
    local function strip_ansi(text)
      return text:gsub("\x1b%[[0-9;]*m", "")
    end

    local function map_omp_command(cmd)
      local mapped_type = omp_command_map[cmd.type]
      if not mapped_type then
        return cmd
      end
      local mapped = vim.deepcopy(cmd)
      mapped.type = mapped_type
      return mapped
    end

    require("pi").setup({
      cli = {
        bin = "omp",
        args = { "--mode=rpc-ui" },
      },
      rpc = {
        map_command = map_omp_command,
        map_event = function(msg, ctx)
          if msg.type == "command_output" then
            local text = strip_ansi(msg.text or "")
            if text ~= "" then
              vim.schedule(function()
                require("pi.notify").info(text)
              end)
            end
            return nil
          end
          if msg.type == "ready" then
            return nil
          end
          if msg.type == "response" and msg.command == "get_available_commands" then
            local mapped = vim.deepcopy(msg)
            mapped.command = "get_commands"
            if mapped.data then
              mapped.data.commands = normalize_omp_commands(mapped.data.commands)
            end
            return mapped
          end
          if msg.type == "available_commands_update" then
            ctx.set_commands(normalize_omp_commands(msg.commands))
            return nil
          end
          return msg
        end,
      },
      statusline = {
        layout = {
          left = { "context", "  ", "cost", "  ", "attention" },
          right = { "model", "   ", "thinking" },
        },
      },
    })

    local pi = require("pi")
    -- ==========================================
    -- 2. Global Mappings & Commands
    -- ==========================================

    -- Provided Global Mappings
    vim.keymap.set({ "n", "v" }, "<Leader>pp", function()
      require("pi").toggle({ layout = "side" })
    end, { desc = "Pi layout=side" })
    vim.keymap.set({ "n", "v" }, "<Leader>pf", function()
      vim.cmd("Pi layout=float")
    end, { desc = "Pi float" })
    vim.keymap.set({ "n", "v" }, "<Leader>pl", "<Cmd>PiToggleLayout<CR>", { desc = "Pi toggle layout" })
    vim.keymap.set({ "n", "v" }, "<Leader>pc", "<Cmd>PiContinue<CR>", { desc = "Pi continue last session" })
    vim.keymap.set({ "n", "v" }, "<Leader>pr", "<Cmd>PiResume<CR>", { desc = "Pi resume past session" })
    vim.keymap.set({ "n", "v" }, "<Leader>pM", "<Cmd>PiSendMention<CR>", { desc = "Pi mention file/selection" })
    vim.keymap.set({ "n", "v" }, "<Leader>pm", "<Cmd>PiSelectModelAll<CR>", { desc = "Pi select model" }) -- Existing command for model selection
    vim.keymap.set({ "n", "v" }, "<Leader>pa", "<Cmd>PiAttention<CR>", { desc = "Pi open next attention request" })

    -- --- New Commands for Model Selection ---

    local Models = require("pi.models")
    local Sessions = require("pi.sessions.manager")

    -- Command to list available models
    vim.api.nvim_create_user_command("PiGetAvailableModels", function()
      local session = Sessions.get()
      if not session or not session.rpc:is_running() then
        print("pi.nvim is not running. Open the chat first.")
        return
      end
      Models.with_available(session, function(models)
        print("Available pi.nvim models:")
        for i, model in ipairs(models) do
          print(string.format("%d. %s", i, Models.format_label(model)))
        end
      end)
    end, {
      desc = "[pi.nvim] List available AI models",
    })

    -- Command to set a specific model by id
    vim.api.nvim_create_user_command("PiSetModel", function(opts)
      local model_name = vim.fn.trim(opts.args)
      if model_name == "" then
        print("Error: Model name is required. Usage: :PiSetModel <model_id>")
        print("Use :PiGetAvailableModels to see available models.")
        return
      end
      local session = Sessions.get()
      if not session or not session.rpc:is_running() then
        print("pi.nvim is not running. Open the chat first.")
        return
      end
      Models.with_available(session, function(models)
        local found = nil
        for _, m in ipairs(models) do
          if m.id == model_name then
            found = m
            break
          end
        end
        if not found then
          print("Model '" .. model_name .. "' not found among available models.")
          return
        end
        Models.set(session, found)
      end)
    end, {
      desc = "[pi.nvim] Set the AI model by id",
      nargs = "*",
    })

    -- Command to print current state
    vim.api.nvim_create_user_command("PiGetState", function()
      local session = Sessions.get()
      if not session or not session.rpc:is_running() then
        print("pi.nvim is not running. Open the chat first.")
        return
      end
      session.rpc:send({ type = "get_state" }, function(res)
        vim.schedule(function()
          if not res.success then
            print("Could not retrieve pi.nvim state: " .. (res.error or "unknown error"))
            return
          end
          local data = res.data or {}
          local model = data.model
          print("Current pi.nvim state:")
          print("  Model: " .. (model and (model.id .. "  [" .. (model.provider or "?") .. "]") or "N/A"))
          print("  Thinking: " .. (data.thinkingLevel or "N/A"))
          print("  Auto-compaction: " .. tostring(data.autoCompactionEnabled))
        end)
      end)
    end, {
      desc = "[pi.nvim] Get the current AI model state",
    })

    -- End of New Commands ---

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
        vim.opt_local.spell = false
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
        map(event.buf, "<M-m>", pi.cycle_model) -- This is the direct call to pi.cycle_model
        map(event.buf, "<M-M>", pi.select_model_all) -- This is the direct call to pi.select_model_all
        map(event.buf, "<M-t>", pi.cycle_thinking_level)
        map(event.buf, "<M-T>", pi.select_thinking_level)

        -- Sessions & context
        map(event.buf, "<M-n>", pi.new_session)
        map(event.buf, "<M-x>", pi.compact)

        -- Override <CR> to intercept /model and /resume before the default submit.
        -- omp in RPC mode can't open pickers for builtins; route these to
        -- pi.nvim's searchable pickers instead. Deferred via vim.schedule
        -- so it runs after the plugin's own _set_keymaps().
        vim.schedule(function()
          vim.keymap.set({ "n", "i" }, "<CR>", function()
            local session = Sessions.get()
            if session then
              local text = session.chat._prompt:text()
              local trimmed = text:match("^%s*(.-)%s*$") or text
              if trimmed:match("^/models?%s*$") then
                session.chat._prompt:clear_text()
                pi.select_model_all()
                return
              end
              if trimmed:match("^/resumes?%s*$") then
                session.chat._prompt:clear_text()
                pi.resume_session()
                return
              end
              session.chat:submit()
            end
          end, { buffer = event.buf, desc = "Submit π prompt (with /model and /resume interception)" })
        end)

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
