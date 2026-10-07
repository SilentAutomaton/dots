local preview = {}

-- Same renderer yazi uses, so a document looks identical in both places.
local function render_preview()
  local width = vim.api.nvim_win_get_width(preview.win) - 2
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_win_set_buf(preview.win, buf)
  local channel = vim.api.nvim_open_term(buf, {})
  vim.system(
    { "glow", "-s", "dark", "-w", tostring(width), preview.source },
    { env = { CLICOLOR_FORCE = "1" }, text = true },
    vim.schedule_wrap(function(result)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      local text = (result.stdout ~= "" and result.stdout or result.stderr):gsub("\n", "\r\n")
      vim.api.nvim_chan_send(channel, text)
      vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(preview.win) and vim.api.nvim_win_get_buf(preview.win) == buf then
          vim.api.nvim_win_set_cursor(preview.win, { 1, 0 })
        end
      end, 20)
    end)
  )
end

local function toggle_preview()
  if preview.win and vim.api.nvim_win_is_valid(preview.win) then
    vim.api.nvim_win_close(preview.win, true)
    preview.win = nil
    return
  end
  preview.source = vim.api.nvim_buf_get_name(0)
  local origin = vim.api.nvim_get_current_win()
  vim.cmd("vsplit")
  preview.win = vim.api.nvim_get_current_win()
  for option, value in pairs({ number = false, relativenumber = false, signcolumn = "no", list = false }) do
    vim.wo[preview.win][option] = value
  end
  render_preview()
  vim.api.nvim_set_current_win(origin)
end

local group = vim.api.nvim_create_augroup("user_markdown_preview", {})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "markdown",
  callback = function(event)
    vim.keymap.set("n", "<leader>mp", toggle_preview, { buffer = event.buf, desc = "Preview with glow" })
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  pattern = "*.md",
  callback = function(event)
    if preview.win and vim.api.nvim_win_is_valid(preview.win) and event.match == preview.source then
      render_preview()
    end
  end,
})

require("image").setup({
  backend = "kitty",
  processor = "magick_cli",
  integrations = {
    markdown = {
      enabled = true,
      clear_in_insert_mode = true,
      download_remote_images = false,
      only_render_image_at_cursor = false,
      filetypes = { "markdown" },
    },
  },
  max_width_window_percentage = 60,
  max_height_window_percentage = 40,
  window_overlap_clear_enabled = true,
  window_overlap_clear_ft_ignore = { "blink-cmp-menu", "blink-cmp-documentation", "blink-cmp-signature", "" },
  kitty_method = "normal",
})

require("mkdnflow").setup({
  modules = {
    bib = false,
    buffers = true,
    conceal = false,
    cursor = true,
    folds = false,
    links = true,
    lists = true,
    maps = true,
    paths = true,
    tables = true,
    yaml = false,
  },
  links = { transform_explicit = false, conceal = false },
  mappings = {
    MkdnEnter = { { "n", "v" }, "<CR>" },
    MkdnNextLink = { "n", "<Tab>" },
    MkdnPrevLink = { "n", "<S-Tab>" },
    MkdnGoBack = { "n", "<BS>" },
    MkdnNextHeading = { "n", "]]" },
    MkdnPrevHeading = { "n", "[[" },
    MkdnToggleToDo = { { "n", "v" }, "<C-Space>" },
    MkdnNewListItemBelowInsert = { "n", "o" },
    MkdnNewListItemAboveInsert = { "n", "O" },
    -- Insert-mode Tab belongs to completion and snippets.
    MkdnTableNextCell = false,
    MkdnTablePrevCell = false,
    MkdnTab = false,
    MkdnSTab = false,
    MkdnFollowLink = false,
    MkdnNewListItem = false,
    MkdnExtendList = false,
    MkdnTableNextRow = false,
    MkdnFoldSection = false,
    MkdnUnfoldSection = false,
  },
})
