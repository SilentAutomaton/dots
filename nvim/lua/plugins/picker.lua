local function fzf(command, opts)
  return function()
    require("fzf-lua")[command](opts)
  end
end

return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader><space>", fzf("files"), desc = "Find files" },
      { "<leader>/", fzf("live_grep"), desc = "Grep" },
      { "<leader>,", fzf("buffers"), desc = "Buffers" },
      { "<leader>:", fzf("command_history"), desc = "Command history" },
      { "<leader>ff", fzf("files"), desc = "Files" },
      { "<leader>fg", fzf("git_files"), desc = "Git files" },
      { "<leader>fr", fzf("oldfiles", { cwd_only = true }), desc = "Recent files" },
      { "<leader>fb", fzf("buffers"), desc = "Buffers" },
      { "<leader>sg", fzf("live_grep"), desc = "Grep" },
      { "<leader>sw", fzf("grep_cword"), desc = "Word under cursor" },
      { "<leader>sw", fzf("grep_visual"), mode = "x", desc = "Selection" },
      { "<leader>sb", fzf("lgrep_curbuf"), desc = "Buffer lines" },
      { "<leader>sd", fzf("diagnostics_workspace"), desc = "Diagnostics" },
      { "<leader>ss", fzf("lsp_document_symbols"), desc = "Symbols" },
      { "<leader>sk", fzf("keymaps"), desc = "Keymaps" },
      { "<leader>sh", fzf("helptags"), desc = "Help" },
      { "<leader>sR", fzf("resume"), desc = "Resume last search" },
      { "<leader>st", fzf("grep", { search = "TODO" .. "(review)", no_esc = false }), desc = "Review marks" },
    },
    opts = {
      winopts = { border = "rounded", backdrop = 100, preview = { border = "rounded" } },
      fzf_colors = true,
    },
  },
}
