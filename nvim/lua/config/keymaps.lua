local map = vim.keymap.set

map("n", "<Esc>", "<Cmd>nohlsearch<CR><Esc>")
map({ "n", "i", "x" }, "<C-s>", "<Cmd>write<CR><Esc>", { desc = "Save" })

map("x", "<", "<gv")
map("x", ">", ">gv")
map("x", "J", ":move '>+1<CR>gv=gv", { silent = true, desc = "Move lines down" })
map("x", "K", ":move '<-2<CR>gv=gv", { silent = true, desc = "Move lines up" })
map("x", "<leader>p", '"_dP', { desc = "Paste over, keep register" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window below" })
map("n", "<C-k>", "<C-w>k", { desc = "Window above" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Taller window" })
map("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Shorter window" })
map("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Narrower window" })
map("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Wider window" })
map("n", "<leader>-", "<C-w>s", { desc = "Split below" })
map("n", "<leader>|", "<C-w>v", { desc = "Split right" })
map("n", "<leader>wd", "<C-w>c", { desc = "Close window" })

map("n", "<leader>bb", "<Cmd>edit #<CR>", { desc = "Other buffer" })
map("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "Close buffer" })
map("n", "<leader>bo", "<Cmd>%bdelete|edit#|bdelete#<CR>", { desc = "Close other buffers" })

map("n", "<leader>xq", function()
  vim.cmd(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and "cclose" or "copen")
end, { desc = "Toggle quickfix" })
map("n", "<leader>xl", function()
  vim.cmd(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and "lclose" or "silent! lopen")
end, { desc = "Toggle location list" })

map("n", "<leader>qq", "<Cmd>qa<CR>", { desc = "Quit all" })
map("n", "<leader>l", "<Cmd>Lazy<CR>", { desc = "Plugins" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })

map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

local function jump_to(severity, count)
  return function()
    vim.diagnostic.jump({ count = count, severity = severity, float = true })
  end
end

map("n", "]e", jump_to(vim.diagnostic.severity.ERROR, 1), { desc = "Next error" })
map("n", "[e", jump_to(vim.diagnostic.severity.ERROR, -1), { desc = "Previous error" })
map("n", "]w", jump_to(vim.diagnostic.severity.WARN, 1), { desc = "Next warning" })
map("n", "[w", jump_to(vim.diagnostic.severity.WARN, -1), { desc = "Previous warning" })

map("n", "<leader>th", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Inlay hints" })
map("n", "<leader>tl", "<Cmd>setlocal wrap!<CR>", { desc = "Line wrap" })

local virtual_text = vim.diagnostic.config().virtual_text
map("n", "<leader>tx", function()
  local shown = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not shown and virtual_text })
end, { desc = "Diagnostic text" })

local function relative_path()
  return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
end

map("n", "<leader>yp", function()
  local location = relative_path() .. ":" .. vim.fn.line(".")
  vim.fn.setreg("+", location)
  vim.notify(location)
end, { desc = "Copy path:line" })

-- Produces a reference an agent can act on: location plus the code itself.
map("x", "<leader>yp", function()
  local first, last = vim.fn.line("v"), vim.fn.line(".")
  if first > last then
    first, last = last, first
  end
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  local location = ("%s:%d-%d"):format(relative_path(), first, last)
  local block = { location, "```" .. vim.bo.filetype }
  vim.list_extend(block, lines)
  table.insert(block, "```")
  vim.fn.setreg("+", table.concat(block, "\n"))
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
  vim.notify(location)
end, { desc = "Copy path:lines with code" })
