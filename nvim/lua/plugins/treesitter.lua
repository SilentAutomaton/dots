local parsers = {
  "bash", "c", "cpp", "diff", "git_config", "git_rebase", "gitcommit", "go", "gomod", "gosum",
  "javascript", "json", "kotlin", "lua", "markdown", "markdown_inline", "python", "query",
  "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", {}),
        callback = function(event)
          if not pcall(vim.treesitter.start, event.buf) then
            return
          end
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          if vim.bo[event.buf].filetype ~= "markdown" then
            vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
