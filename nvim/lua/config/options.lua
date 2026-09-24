local opt = vim.opt

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.cursorlineopt = "number"
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.breakindent = true
opt.list = true
opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }
opt.winborder = "rounded"
opt.pumheight = 12
opt.showmode = false

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.shiftround = true

opt.clipboard = "unnamedplus"
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo//"
opt.confirm = true
opt.autoread = true
opt.updatetime = 250
opt.timeoutlen = 400

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.splitright = true
opt.splitbelow = true

opt.foldlevel = 99
opt.foldtext = ""

-- Russian layout reaches normal-mode commands. "." and "," stay untouched:
-- mapping them would break repeat and reverse char search in the English layout.
opt.langmap = table.concat({
  "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ",
  "фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz",
  "х[", "ъ]", "ж\\;", "э'", "б\\,", "ю.", "ё`",
  "Х{", "Ъ}", "Ж:", "Э\\\"", "Б<", "Ю>", "Ё~",
}, ",")

for lhs, rhs in pairs({ ["й"] = "q", ["йф"] = "qa", ["ц"] = "w", ["цй"] = "wq", ["ив"] = "bd", ["ит"] = "bn" }) do
  vim.cmd(("cnoreabbrev <expr> %s getcmdtype() == ':' && getcmdline() == '%s' ? '%s' : '%s'"):format(lhs, lhs, rhs, lhs))
end

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = { severity = { min = vim.diagnostic.severity.WARN }, prefix = "●", spacing = 2 },
  float = { source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    },
  },
})

local group = vim.api.nvim_create_augroup("user_options", {})

-- Files change on disk while an agent works on them.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = group,
  command = "silent! checktime",
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(event.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

function _G.status_git()
  local head = vim.b.gitsigns_head
  if not head or head == "" then
    return ""
  end
  local changes = vim.b.gitsigns_status or ""
  return " " .. head .. (changes ~= "" and " " .. changes or "")
end

opt.statusline = " %<%f %h%m%r%=%{v:lua.status_git()}  %{%v:lua.vim.diagnostic.status()%}  %l:%c  %P "
