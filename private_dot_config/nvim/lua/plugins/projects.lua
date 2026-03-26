return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local workspace = vim.fn.expand("~/Workspaces")
      local dev_paths = { workspace }

      -- Automatically find subdirectories like 'wyssmann.com'
      -- and add them as dev roots so Snacks scans inside them.
      if vim.fn.isdirectory(workspace) == 1 then
        local handle = vim.loop.fs_scandir(workspace)
        if handle then
          while true do
            local name, type = vim.loop.fs_scandir_next(handle)
            if not name then
              break
            end
            if type == "directory" and not name:match("^%.") then
              table.insert(dev_paths, workspace .. "/" .. name)
            end
          end
        end
      end

      opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
        sources = {
          projects = {
            dev = dev_paths,
            patterns = { ".git", "go.mod", "package.json", "terraform" },
          },
        },
      })
    end,
    keys = {
      {
        "<leader>fp",
        function()
          Snacks.picker.projects()
        end,
        desc = "Projects",
      },
    },
  },
}
