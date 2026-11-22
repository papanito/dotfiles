-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Use the SHELL env var if it exists, otherwise fallback to zsh
-- We use 'zsh' instead of a hardcoded Nix path to keep the config portable
local shell = os.getenv("SHELL")
if shell and shell:match("zsh") then
  vim.opt.shell = shell
else
  vim.opt.shell = "zsh"
end

-- Ensure filetype/highlighting persist across session restore (auto-session).
vim.opt.sessionoptions:append("localoptions")

-- Auto-reload files changed on disk and auto-save on buffer switch
vim.opt.autoread = true -- Already set by LazyVim, but make it explicit
vim.opt.autowriteall = true -- Save modified buffers when switching away or exiting
