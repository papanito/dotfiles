-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- Global mapping — works from any normal buffer.
map("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Find Projects" })

-- Snacks explorer has buffer-local bindings that swallow <leader>fp.
-- Override it specifically inside snacks_explorer buffers: escape to the
-- previous window first (wincmd p), then open Telescope via vim.schedule
-- so the window switch settles before Telescope tries to render.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_explorer",
  callback = function(ev)
    vim.keymap.set("n", "<leader>fp", function()
      vim.cmd("wincmd p")
      vim.schedule(function()
        vim.cmd("Telescope projects")
      end)
    end, { buffer = ev.buf, desc = "Find Projects" })
  end,
})
-- Single <Esc> to exit terminal mode in plain :terminal buffers (filetype
-- "terminal"). Snacks.terminal has its own double-<Esc> handler for
-- "snacks_terminal" buffers, so we only map this for non-Snacks terminals
-- to avoid conflict.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "terminal",
  callback = function(ev)
    vim.keymap.set("t", "<esc>", "<C-\\><C-n>", { buffer = ev.buf, desc = "Exit terminal mode" })
  end,
})
