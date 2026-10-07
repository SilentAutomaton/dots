-- Claude Code runs in its own terminal; here it only talks to nvim over the IDE protocol (/ide).
require("claudecode").setup({
  terminal = { provider = "none" },
})

local map = vim.keymap.set

map("n", "<leader>ab", "<Cmd>ClaudeCodeAdd %<CR>", { desc = "Add file to agent" })
map("x", "<leader>as", "<Cmd>ClaudeCodeSend<CR>", { desc = "Send selection to agent" })
map("n", "<leader>aa", "<Cmd>ClaudeCodeDiffAccept<CR>", { desc = "Accept agent diff" })
map("n", "<leader>ad", "<Cmd>ClaudeCodeDiffDeny<CR>", { desc = "Deny agent diff" })
map("n", "<leader>ai", "<Cmd>ClaudeCodeStatus<CR>", { desc = "Agent connection status" })
