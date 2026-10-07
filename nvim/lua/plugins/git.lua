local function git_ok(...)
  vim.fn.system({ "git", ... })
  return vim.v.shell_error == 0
end

local function in_repo()
  if git_ok("rev-parse", "--git-dir") then
    return true
  end
  vim.notify("Not a git repository.", vim.log.levels.WARN)
  return false
end

local function base_branch()
  for _, ref in ipairs({ "origin/HEAD", "origin/main", "origin/master", "main", "master" }) do
    if git_ok("rev-parse", "--verify", "--quiet", ref) then
      return ref
    end
  end
end

local function review_branch()
  if not in_repo() then
    return
  end
  local base = base_branch()
  if not base then
    vim.notify("No base branch found. Neither origin/HEAD, main nor master exists. Run :CodeDiff <ref>...HEAD.", vim.log.levels.WARN)
    return
  end
  vim.cmd("CodeDiff " .. base .. "...HEAD")
end

local function working_tree()
  if in_repo() then
    vim.cmd("CodeDiff")
  end
end

local function last_commit()
  if not in_repo() then
    return
  end
  if git_ok("rev-parse", "--verify", "--quiet", "HEAD~1") then
    vim.cmd("CodeDiff HEAD~1 HEAD")
  else
    vim.notify("Only one commit: showing the history instead.")
    vim.cmd("CodeDiff history")
  end
end

-- The agent commits itself: uncommitted changes first, otherwise what it just committed.
local function smart_diff()
  if not in_repo() then
    return
  end
  if vim.fn.system({ "git", "status", "--porcelain" }) ~= "" then
    vim.cmd("CodeDiff")
  else
    last_commit()
  end
end

local function lazygit()
  if vim.fn.executable("lazygit") == 0 then
    vim.notify("lazygit is not installed.", vim.log.levels.WARN)
    return
  end
  local width, height = math.floor(vim.o.columns * 0.92), math.floor(vim.o.lines * 0.9)
  local win = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
  })
  vim.fn.jobstart({ "lazygit" }, {
    term = true,
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      vim.cmd("silent! checktime")
    end,
  })
  vim.cmd.startinsert()
end

local menu = {
  { "Правки сейчас или последний коммит", smart_diff },
  { "Только незакоммиченные правки", working_tree },
  { "Последний коммит", last_commit },
  { "Ветка против базовой", review_branch },
  { "История текущего файла", function() vim.cmd("CodeDiff history %") end },
  { "Лог репозитория", function() vim.cmd("CodeDiff history") end },
  { "Статус, коммит, правка сообщения (fugitive)", function() vim.cmd("Git") end },
  { "Blame файла", function() vim.cmd("Git blame") end },
  { "Lazygit", lazygit },
}

local function git_menu()
  require("plugins.picker").load()
  vim.ui.select(menu, { prompt = "Git", format_item = function(item) return item[1] end }, function(choice)
    if choice then
      choice[2]()
    end
  end)
end

-- The commit-msg hook opens the agent's message for editing unless this file exists.
local review_flag = vim.fs.joinpath(vim.fn.fnamemodify(vim.fn.stdpath("state"), ":h"), "commit-review-off")

local function toggle_commit_review()
  if vim.uv.fs_stat(review_flag) then
    os.remove(review_flag)
    vim.notify("agent commit message review: on")
  else
    io.open(review_flag, "w"):close()
    vim.notify("agent commit message review: off")
  end
end

local map = vim.keymap.set

map("n", "<leader>gd", smart_diff, { desc = "Changes or last commit" })
map("n", "<leader>gw", working_tree, { desc = "Uncommitted changes" })
map("n", "<leader>gh", last_commit, { desc = "Last commit" })
map("n", "<leader>gD", review_branch, { desc = "Branch against base" })
map("n", "<leader>gf", "<Cmd>CodeDiff history %<CR>", { desc = "File history" })
map("n", "<leader>gl", "<Cmd>CodeDiff history<CR>", { desc = "Repository log" })
map("n", "<leader>gg", git_menu, { desc = "Git menu" })
map("n", "<leader>gG", lazygit, { desc = "Lazygit" })
map("n", "<leader>gs", "<Cmd>Git<CR>", { desc = "Status (fugitive)" })
map("n", "<leader>gc", "<Cmd>Git commit<CR>", { desc = "Commit" })
map("n", "<leader>gB", "<Cmd>Git blame<CR>", { desc = "Blame file" })
map("n", "<leader>gv", "<Cmd>Gvdiffsplit<CR>", { desc = "Diff file against index" })
map("n", "<leader>tc", toggle_commit_review, { desc = "Agent commit message review" })

require("codediff").setup({
  explorer = { line_stats = { enabled = true } },
})

require("review").setup({})

map("n", "<leader>vr", "<Cmd>Review<CR>", { desc = "Review changes" })
map("n", "<leader>vc", "<Cmd>Review commits<CR>", { desc = "Review commits" })
map("n", "<leader>vb", "<Cmd>Review branch<CR>", { desc = "Review branch" })
map({ "n", "x" }, "<leader>vn", ":Review note<CR>", { desc = "Note on this line" })
map("n", "<leader>ve", "<Cmd>Review edit<CR>", { desc = "Edit comment" })
map("n", "<leader>vd", "<Cmd>Review delete<CR>", { desc = "Delete comment" })
map("n", "<leader>vx", "<Cmd>Review export<CR>", { desc = "Export comments" })

require("gitsigns").setup({
  signs_staged_enable = true,
  attach_to_untracked = true,
  preview_config = { border = "rounded" },
  on_attach = function(bufnr)
    local gitsigns = require("gitsigns")
    local function bmap(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    local function selected_lines()
      return { vim.fn.line("."), vim.fn.line("v") }
    end

    bmap("n", "]h", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end, "Next hunk")
    bmap("n", "[h", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end, "Previous hunk")
    bmap("n", "]H", function()
      gitsigns.nav_hunk("last")
    end, "Last hunk")
    bmap("n", "[H", function()
      gitsigns.nav_hunk("first")
    end, "First hunk")

    bmap("n", "<leader>hs", gitsigns.stage_hunk, "Stage or unstage hunk")
    bmap("x", "<leader>hs", function()
      gitsigns.stage_hunk(selected_lines())
    end, "Stage or unstage lines")
    bmap("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
    bmap("x", "<leader>hr", function()
      gitsigns.reset_hunk(selected_lines())
    end, "Reset lines")
    bmap("n", "<leader>hS", gitsigns.stage_buffer, "Stage file")
    bmap("n", "<leader>hR", gitsigns.reset_buffer, "Reset file")
    bmap("n", "<leader>hU", gitsigns.reset_buffer_index, "Unstage file")
    bmap("n", "<leader>hp", gitsigns.preview_hunk_inline, "Preview hunk")
    bmap("n", "<leader>hd", gitsigns.diffthis, "Diff against index")
    bmap("n", "<leader>hq", gitsigns.setqflist, "File hunks to quickfix")
    bmap("n", "<leader>hQ", function()
      gitsigns.setqflist("all")
    end, "Repository hunks to quickfix")
    bmap("n", "<leader>gb", gitsigns.blame_line, "Blame line")
    bmap("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Line blame")
    bmap("n", "<leader>tw", gitsigns.toggle_word_diff, "Word diff")
    bmap("n", "<leader>td", gitsigns.toggle_deleted, "Deleted lines")
    bmap({ "o", "x" }, "ih", gitsigns.select_hunk, "Hunk")
  end,
})
