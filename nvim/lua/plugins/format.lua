local save_formatting = { go = true }

local function toggle_format_on_save()
  local filetype = vim.bo.filetype
  save_formatting[filetype] = not save_formatting[filetype] or nil
  vim.notify(("format on save for %s: %s"):format(filetype, save_formatting[filetype] and "on" or "off"))
end

require("conform").setup({
  formatters_by_ft = {
    python = { "ruff_organize_imports", "ruff_format" },
    javascript = { "prettier", "biome", stop_after_first = true },
    javascriptreact = { "prettier", "biome", stop_after_first = true },
    typescript = { "prettier", "biome", stop_after_first = true },
    typescriptreact = { "prettier", "biome", stop_after_first = true },
    json = { "prettier", "biome", stop_after_first = true },
    kotlin = { "ktlint" },
    sh = { "shfmt" },
    bash = { "shfmt" },
  },
  default_format_opts = { lsp_format = "fallback" },
  formatters = {
    -- Prettier only where the project chose it; biome covers the rest.
    prettier = { require_cwd = true },
  },
  -- Other languages format on demand, so opening someone else's file never rewrites it.
  format_on_save = function(bufnr)
    if save_formatting[vim.bo[bufnr].filetype] then
      return { timeout_ms = 1000 }
    end
  end,
})

vim.api.nvim_create_user_command("FormatOnSaveToggle", toggle_format_on_save, {})

vim.keymap.set({ "n", "x" }, "<leader>cf", function()
  require("conform").format({ async = true })
end, { desc = "Format" })
vim.keymap.set("n", "<leader>tf", toggle_format_on_save, { desc = "Format on save" })
