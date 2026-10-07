-- codediff would fetch a prebuilt watcher binary from GitHub; it falls back to polling without it.
vim.env.CODEDIFF_WATCHER_NO_AUTO_INSTALL = "1"

local function gh(path)
  return "https://github.com/" .. path
end

-- Declared before vim.pack.add so a fresh install also runs the build steps.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("user_pack", {}),
  callback = function(event)
    local name, kind = event.data.spec.name, event.data.kind
    if kind ~= "install" and kind ~= "update" then
      return
    end
    if name == "nvim-treesitter" then
      if not event.data.active then
        vim.cmd.packadd(name)
      end
      vim.cmd("TSUpdate")
    elseif name == "codediff.nvim" then
      -- A local build keeps the plugin from downloading a prebuilt library.
      vim.system({ "./build.sh" }, { cwd = event.data.path }):wait()
    end
  end,
})

vim.pack.add({
  gh("folke/which-key.nvim"),
  gh("tpope/vim-sleuth"),
  gh("nvim-tree/nvim-web-devicons"),
  gh("ibhagwan/fzf-lua"),
  { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
  gh("neovim/nvim-lspconfig"),
  gh("stevearc/conform.nvim"),
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  gh("tpope/vim-fugitive"),
  gh("lewis6991/gitsigns.nvim"),
  gh("esmuellert/codediff.nvim"),
  gh("MunifTanjim/nui.nvim"),
  { src = gh("georgeguimaraes/review.nvim"), version = vim.version.range("*") },
  gh("coder/claudecode.nvim"),
  gh("3rd/image.nvim"),
  gh("jakewvincent/mkdnflow.nvim"),
}, { confirm = true })

for _, module in ipairs({
  "editing", "picker", "completion", "lsp", "format", "treesitter", "git", "agent", "markdown",
}) do
  -- The commit message editor that the git hook opens must not register a second IDE server.
  if not (module == "agent" and vim.env.NVIM_COMMIT_REVIEW == "1") then
    require("plugins." .. module)
  end
end
