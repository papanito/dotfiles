-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augrou-- Create a custom augroup for your autocmds
-- Check for files modified on disk: trigger autoread on focus, buffer enter,
-- and on a timer (every 2s) for background changes while nvim has focus.
local autoread_group = vim.api.nvim_create_augroup("papanito_autoread", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = autoread_group,
  callback = function(args)
    -- Skip terminal and special buffers
    if vim.bo[args.buf].buftype ~= "" then return end
    -- Check if file exists and was modified externally
    if vim.fn.filereadable(vim.fn.expand(args.file)) == 1 then
      vim.cmd("silent! checktime " .. args.buf)
    end
  end,
})

-- Set upperiodic updatetime for CursorHold (ms) — lower = more responsive autoread
vim.opt.updatetime = 2000
