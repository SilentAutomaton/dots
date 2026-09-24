local function base_branch()
  for _, ref in ipairs({ "origin/HEAD", "origin/main", "origin/master", "main", "master" }) do
    vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", ref })
    if vim.v.shell_error == 0 then
      return ref
    end
  end
end

local function review_branch()
  local base = base_branch()
  if not base then
    vim.notify("No base branch found. Neither origin/HEAD, main nor master exists. Run :DiffviewOpen <ref>...HEAD.", vim.log.levels.WARN)
    return
  end
  vim.cmd("DiffviewOpen " .. base .. "...HEAD")
end

-- Marks a change for rework without touching the index; the pre-commit hook refuses it.
-- Split so the commit hook does not take the literal for an open mark.
local review_mark = "TODO" .. "(review): "

local function mark_for_review()
  local line = vim.fn.mode():match("[vV]") and math.min(vim.fn.line("v"), vim.fn.line(".")) or vim.fn.line(".")
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
  local indent = vim.fn.getline(line):match("^%s*")
  local commentstring = vim.bo.commentstring ~= "" and vim.bo.commentstring or "# %s"
  local text = indent .. commentstring:format(review_mark)
  vim.api.nvim_buf_set_lines(0, line - 1, line - 1, false, { text })
  local column = #indent + commentstring:find("%%s") - 1 + #review_mark
  vim.api.nvim_win_set_cursor(0, { line, column })
  vim.cmd(column >= #text and "startinsert!" or "startinsert")
end

return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Gclog", "Gedit" },
    keys = {
      { "<leader>gs", "<Cmd>Git<CR>", desc = "Status (fugitive)" },
      { "<leader>gc", "<Cmd>Git commit<CR>", desc = "Commit" },
      { "<leader>gB", "<Cmd>Git blame<CR>", desc = "Blame file" },
      { "<leader>gv", "<Cmd>Gvdiffsplit<CR>", desc = "Diff file against index" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs_staged_enable = true,
      attach_to_untracked = true,
      preview_config = { border = "rounded" },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        local function selected_lines()
          return { vim.fn.line("."), vim.fn.line("v") }
        end

        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, "Next hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, "Previous hunk")
        map("n", "]H", function()
          gitsigns.nav_hunk("last")
        end, "Last hunk")
        map("n", "[H", function()
          gitsigns.nav_hunk("first")
        end, "First hunk")

        map("n", "<leader>hs", gitsigns.stage_hunk, "Stage or unstage hunk")
        map("x", "<leader>hs", function()
          gitsigns.stage_hunk(selected_lines())
        end, "Stage or unstage lines")
        map("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
        map("x", "<leader>hr", function()
          gitsigns.reset_hunk(selected_lines())
        end, "Reset lines")
        map("n", "<leader>hS", gitsigns.stage_buffer, "Stage file")
        map("n", "<leader>hR", gitsigns.reset_buffer, "Reset file")
        map("n", "<leader>hU", gitsigns.reset_buffer_index, "Unstage file")
        map("n", "<leader>hp", gitsigns.preview_hunk_inline, "Preview hunk")
        map("n", "<leader>hd", gitsigns.diffthis, "Diff against index")
        map("n", "<leader>hq", gitsigns.setqflist, "File hunks to quickfix")
        map("n", "<leader>hQ", function()
          gitsigns.setqflist("all")
        end, "Repository hunks to quickfix")
        map("n", "<leader>gb", gitsigns.blame_line, "Blame line")
        map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Line blame")
        map("n", "<leader>tw", gitsigns.toggle_word_diff, "Word diff")
        map("n", "<leader>td", gitsigns.toggle_deleted, "Deleted lines")
        map({ "n", "x" }, "<leader>ht", mark_for_review, "Mark for review")
        map({ "o", "x" }, "ih", gitsigns.select_hunk, "Hunk")
      end,
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gd", "<Cmd>DiffviewOpen<CR>", desc = "Review working tree" },
      { "<leader>gD", review_branch, desc = "Review branch against base" },
      { "<leader>gf", "<Cmd>DiffviewFileHistory %<CR>", desc = "File history" },
      { "<leader>gl", "<Cmd>DiffviewFileHistory<CR>", desc = "Repository log" },
    },
    opts = {
      enhanced_diff_hl = true,
      file_panel = { win_config = { width = 40 } },
      keymaps = {
        view = { { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close review" } } },
        file_panel = { { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close review" } } },
        file_history_panel = { { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close review" } } },
      },
    },
  },
}
