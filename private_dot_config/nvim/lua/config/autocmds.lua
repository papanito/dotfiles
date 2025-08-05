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
-- It's a good practice to clear the group to prevent duplicate autocmds
local my_augroup = vim.api.nvim_create_augroup("MyCustomAutocmds", { clear = true })

-- Now you can add your custom autocmds here
vim.api.nvim_create_autocmd("BufEnter", {
  group = my_augroup,
  callback = function()
    -- Get the full path of the current file's directory
    local current_file_dir = vim.fn.fnamemodify(vim.fn.bufname(), ":p:h")

    -- Check if the directory exists and is different from the current working directory
    if current_file_dir and vim.fn.isdirectory(current_file_dir) == 1 then
      if current_file_dir ~= vim.fn.getcwd() then
        -- Set the current working directory to the file's directory
        vim.api.nvim_set_current_dir(current_file_dir)
      end
    end
  end,
})

-- You can add more autocmds below
-- For example, to make sure the CWD is always the directory of the current file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = my_augroup,
  pattern = "*",
  callback = function()
    local dir = vim.fn.fnamemodify(vim.fn.bufname(), ":p:h")
    if dir and vim.fn.isdirectory(dir) == 1 then
      vim.cmd("silent! cd " .. dir)
    end
  end,
})