return {
  "sudo-tee/opencode.nvim",
  -- Optional: markdown rendering of the OpenCode panel output.
  dependencies = {
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        anti_conceal = { enabled = false },
        file_types = { "markdown", "opencode_output" },
      },
      ft = { "markdown", "opencode_output" },
    },
  },
  -- Requires `opencode` on PATH (installed via home-manager) with a provider
  -- connected (`opencode serve` picks up auth from ~/.local/share/opencode).
  opts = {},
}
