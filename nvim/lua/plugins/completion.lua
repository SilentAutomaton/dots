require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
  },
  completion = {
    list = { selection = { preselect = false, auto_insert = true } },
    menu = { border = "rounded", scrollbar = false },
    documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
  },
  signature = { enabled = true, window = { border = "rounded" } },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  -- The Lua matcher needs no prebuilt library from GitHub.
  fuzzy = { implementation = "lua" },
  cmdline = { completion = { menu = { auto_show = true } } },
})
