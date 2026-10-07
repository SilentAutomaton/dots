local M = {}

local ready = false

-- fzf-lua costs about 20 ms at start, so it is set up on the first picker call.
function M.load()
  if not ready then
    ready = true
    local fzf = require("fzf-lua")
    fzf.setup({
      winopts = { border = "rounded", backdrop = 100, preview = { border = "rounded" } },
      fzf_colors = true,
    })
    -- The git menu uses vim.ui.select.
    fzf.register_ui_select()
  end
  return require("fzf-lua")
end

local function map(lhs, command, desc, opts, mode)
  vim.keymap.set(mode or "n", lhs, function()
    M.load()[command](opts)
  end, { desc = desc })
end

map("<leader><space>", "files", "Find files")
map("<leader>/", "live_grep", "Grep")
map("<leader>,", "buffers", "Buffers")
map("<leader>:", "command_history", "Command history")
map("<leader>ff", "files", "Files")
map("<leader>fg", "git_files", "Git files")
map("<leader>fr", "oldfiles", "Recent files", { cwd_only = true })
map("<leader>fb", "buffers", "Buffers")
map("<leader>sg", "live_grep", "Grep")
map("<leader>sw", "grep_cword", "Word under cursor")
map("<leader>sw", "grep_visual", "Selection", nil, "x")
map("<leader>sb", "lgrep_curbuf", "Buffer lines")
map("<leader>sd", "diagnostics_workspace", "Diagnostics")
map("<leader>ss", "lsp_document_symbols", "Symbols")
map("<leader>sk", "keymaps", "Keymaps")
map("<leader>sh", "helptags", "Help")
map("<leader>sR", "resume", "Resume last search")

return M
