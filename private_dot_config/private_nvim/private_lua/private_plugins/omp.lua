return {
  "carderne/pi-nvim",
  config = function()
    require("pi-nvim").setup({
      set_default_keymaps = false,
    })

    local omp_buf = nil
    local omp_win = nil

    local function toggle_omp()
      if omp_win and vim.api.nvim_win_is_valid(omp_win) then
        vim.api.nvim_win_close(omp_win, true)
        omp_win = nil
        return
      end

      if omp_buf and vim.api.nvim_buf_is_valid(omp_buf) then
        vim.cmd("botright vsplit")
        vim.cmd("vertical resize 55")
        vim.api.nvim_win_set_buf(0, omp_buf)
        omp_win = vim.api.nvim_get_current_win()
        vim.cmd("startinsert")
        return
      end

      vim.cmd("botright vsplit")
      vim.cmd("vertical resize 55")
      vim.cmd("term omp")
      omp_buf = vim.api.nvim_get_current_buf()
      omp_win = vim.api.nvim_get_current_win()
      vim.api.nvim_buf_set_name(omp_buf, "omp://terminal")
      vim.cmd("startinsert")
    end

    vim.api.nvim_create_user_command("OmpToggle", toggle_omp, {})

    local map = vim.keymap.set

    -- ==========================================
    -- 1. NORMAL MODE SHORTCUTS (Safe to use Leader)
    -- ==========================================
    map("n", "<leader>oo", "<cmd>OmpToggle<cr>", { desc = "Toggle Omp Panel" })
    map("n", "<leader>op", "<cmd>Pi<cr>", { desc = "Omp: Open Prompt Box" })
    map("n", "<leader>of", "<cmd>PiSendFile<cr>", { desc = "Omp: Send File Path" })
    map("n", "<leader>ob", "<cmd>PiSendBuffer<cr>", { desc = "Omp: Send Entire Buffer" })
    map("v", "<leader>os", ":PiSendSelection<cr>", { desc = "Omp: Send Selection" })

    -- ==========================================
    -- 2. TERMINAL MODE SHORTCUTS (Bypass Omp Stream)
    -- ==========================================

    -- Use Alt+o to close/toggle the Omp window instantly while typing in it
    map("t", "<M-o>", "<cmd>OmpToggle<cr>", { desc = "Toggle Omp Panel from Terminal" })

    -- This lets you jump back to your code without ever pressing Escape.
    map("t", "<C-h>", [[<C-\><C-n><C-w>h]], { silent = true, desc = "Move to Left Window" })
    map("t", "<C-j>", [[<C-\><C-n><C-w>j]], { silent = true, desc = "Move to Lower Window" })
    map("t", "<C-k>", [[<C-\><C-n><C-w>k]], { silent = true, desc = "Move to Upper Window" })
    map("t", "<C-l>", [[<C-\><C-n><C-w>l]], { silent = true, desc = "Move to Right Window" })

    -- Safe escape sequence that omp won't swallow (Ctrl + Space)
    map("t", "<C-Space>", [[<C-\><C-n>]], { desc = "Force Normal Mode in Terminal" })
  end,
}
