return {
  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle" },
    keys = {
      { "<Leader>u", "<Cmd>UndotreeToggle<CR>", desc = "Undo tree" },
    },
    init = function()
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_TreeNodeShape = "◉"
      vim.g.undotree_TreeVertShape = "│"
      vim.g.undotree_TreeNrWidth = 2
      vim.g.undotree_DrawSilent = 1
    end,
  },
}
