return {
  {
    "ahmedkhalf/project.nvim",
    opts = {
      manual_mode = false,
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)

      -- Required: register the Telescope extension so `:Telescope projects` works.
      require("telescope").load_extension("projects")

      local history_path = vim.fn.stdpath("data") .. "/project_nvim/project_history"
      local workspace = vim.fn.expand("~/Workspaces")

      vim.fn.mkdir(vim.fn.fnamemodify(history_path, ":h"), "p")

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

      -- maxdepth 5 to cover nested structures (company/team/project, VM/ subtrees, etc.)
      local find_cmd =
        string.format("find %s -maxdepth 5 -name '.git' -type d 2>/dev/null", vim.fn.shellescape(workspace))
      local handle = io.popen(find_cmd)
      if handle then
        local changed = false
        for line in handle:lines() do
          local project_root = line:gsub("/%.git$", "")
          if not project_set[project_root] then
            table.insert(projects, project_root)
            project_set[project_root] = true
            changed = true
          end
        end
        handle:close()

        if changed then
          local wf = io.open(history_path, "w")
          if wf then
            for _, p in ipairs(projects) do
              wf:write(p .. "\n")
            end
            wf:close()
            pcall(function()
              require("project_nvim.utils.history").load_history()
            end)
          end
        end
      end
    end,
  },
}
