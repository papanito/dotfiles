return {
  "saghen/blink.cmp",
  config = function()
    require("blink-cmp").setup({
      completion = {
        documentation = { auto_show = true, window = { border = "single" } },
        ghost_text = { enabled = true },
        trigger = {
          show_on_trigger_character = true,
        },
        menu = { auto_show = true, border = "single" },
      },
      keymap = {
        ["<c-b>"] = { "scroll_documentation_up", "fallback" },
        ["<c-f>"] = { "scroll_documentation_down", "fallback" },
        ["<c-n>"] = { "select_next", "fallback_to_mappings" },
        ["<c-p>"] = { "select_prev", "fallback_to_mappings" },
        ["<c-space>"] = { "show", "hide" },
        ["<tab>"] = { "select_and_accept", "fallback" },
        ["<enter>"] = { "select_and_accept" },
        preset = "none",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = { ["pi-chat-prompt"] = { "pi" } },
        providers = {
          pi = { module = "pi.completion.blink", name = "Pi", score_offset = 100 },
        },
      },
    })
  end,
}
