return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- ~/.local/bin holds a broken pip copy of pyright that shadows the system one.
      vim.lsp.config("pyright", {
        cmd = { "/usr/bin/pyright-langserver", "--stdio" },
        settings = {
          pyright = { disableOrganizeImports = true },
          python = { analysis = { typeCheckingMode = "standard" } },
        },
      })

      -- Attach without a project biome.json: biome then reads ~/.config/biome/biome.json.
      vim.lsp.config("biome", {
        root_dir = function(bufnr, on_dir)
          on_dir(vim.fs.root(bufnr, { "biome.json", "biome.jsonc", "package.json", ".git" }) or vim.fn.getcwd())
        end,
      })

      vim.lsp.config("clangd", {
        cmd = { "clangd", "--clang-tidy", "--header-insertion=never", "--completion-style=detailed" },
      })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt = true,
            staticcheck = true,
            usePlaceholders = false,
            analyses = { ST1003 = true, unusedparams = true, shadow = true },
            hints = { parameterNames = true, assignVariableTypes = true },
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
            telemetry = { enable = false },
          },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp", {}),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return
          end
          -- pyright owns hover, conform owns TypeScript formatting.
          if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          elseif client.name == "ts_ls" then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end
        end,
      })

      vim.lsp.enable({
        "pyright", "ruff", "ts_ls", "biome", "kotlin_lsp", "clangd", "bashls", "gopls", "lua_ls",
      })
    end,
  },
}
