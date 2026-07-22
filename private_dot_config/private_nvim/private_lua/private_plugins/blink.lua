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
        ["<down>"] = { "select_next", "fallback" },
        ["<up>"] = { "select_prev", "fallback" },
        ["<c-space>"] = { "show", "hide" },
        ["<tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<s-tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<cr>"] = { "accept", "fallback" },
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
