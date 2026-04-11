return {
  {
    "ahmedkhalf/project.nvim",
    opts = {
      manual_mode = false,
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)

      local history_path = vim.fn.stdpath("data") .. "/project_nvim/project_history"
      local workspace = vim.fn.expand("~/Workspaces")

      -- Ensure the directory exists so io.open doesn't fail
      vim.fn.mkdir(vim.fn.fnamemodify(history_path, ":h"), "p")

      -- 1. Load existing projects into a set for O(1) lookup
      local projects = {}
      local project_set = {}
      local f = io.open(history_path, "r")
      if f then
        for line in f:lines() do
          if line ~= "" and not project_set[line] then
            table.insert(projects, line)
            project_set[line] = true
          end
        end
        f:close()
      end

      -- 2. Use 'find' to recursively locate all .git directories
      -- This is faster and more reliable than nested luv loops for deep trees
      local find_cmd = string.format('find %s -maxdepth 3 -name ".git" -type d', workspace)
      local handle = io.popen(find_cmd)
      if handle then
        local changed = false
        for line in handle:lines() do
          -- Strip the /.git suffix to get the project root
          local project_root = line:gsub("/%.git$", "")

          if not project_set[project_root] then
            table.insert(projects, project_root)
            project_set[project_root] = true
            changed = true
          end
        end
        handle:close()

        -- 3. Write back if new projects found
        if changed then
          local wf = io.open(history_path, "w")
          if wf then
            for _, p in ipairs(projects) do
              wf:write(p .. "\n")
            end
            wf:close()
            -- Force refresh the plugin's internal state
            pcall(function()
              require("project_nvim.utils.history").load_history()
            end)
          end
        end
      end
    end,
  },
}
