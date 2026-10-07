vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
vim.cmd.colorscheme("kitty-dim")
require("config.pack")

-- Shift+Enter (CSI u from kitty) inserts a line break
vim.keymap.set("i", "<S-CR>", "<CR>")
