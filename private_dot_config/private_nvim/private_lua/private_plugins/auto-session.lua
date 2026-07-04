return {
  "rmagatti/auto-session",
  lazy = false,

  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
    -- Restore the last session when no session exists for the cwd,
    -- so previously open buffers autoload on every nvim launch.
    auto_restore_last_session = true,
    -- Save and restore sessions even when nvim is launched with file args,
    -- so those buffers are picked up by the next autoload.
    args_allow_files_auto_save = true,
    -- Surface a notification when a session is auto-restored.
    show_auto_restore_notif = true,
    -- log_level = 'debug',
  },
}
