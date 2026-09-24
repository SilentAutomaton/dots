-- Rounded full border echoes Hyprland `rounding = 18`
require("full-border"):setup { type = ui.Border.ROUNDED }

-- git status as a linemode column, branch in the header
require("git"):setup()
require("githead"):setup {
	branch_prefix = "",
	branch_symbol = "",
}

-- MIME from extension instead of spawning file(1) on every entry
require("mime-ext.local"):setup {
	with_files = { makefile = "text/makefile", PKGBUILD = "text/x-sh" },
	fallback_file1 = true,
}

-- vim-style relative numbers and 5j / 3k motions
require("relative-motions"):setup { show_numbers = "relative_absolute", show_motion = true }

require("restore"):setup { position = { "center", w = 70, h = 40 } }

require("bunny"):setup {
	hops = {
		{ key = "h", path = "~",                    desc = "Home" },
		{ key = "p", path = "~/proj",               desc = "Projects" },
		{ key = "c", path = "~/.config",            desc = "Config" },
		{ key = "d", path = "~/down",               desc = "Downloads" },
		{ key = "D", path = "~/docs",               desc = "Documents" },
		{ key = "T", path = "~/docs/tasks",         desc = "Tasks" },
		{ key = "i", path = "~/pix",                desc = "Pictures" },
		{ key = "m", path = "~/mus",                desc = "Music" },
		{ key = "v", path = "~/vids",               desc = "Videos" },
		{ key = "t", path = "/tmp",                 desc = "Tmp" },
		{ key = "M", path = "/mnt",                 desc = "Mnt" },
		{ key = "u", path = "/run/media/silent",    desc = "USB drives" },
		{ key = "g", path = "/run/user/1000/gvfs",  desc = "GVFS mounts" },
	},
	desc_strategy = "path",
	notify = false,
	fuzzy_cmd = "fzf",
}

require("projects"):setup { save = { method = "yazi", parent = true } }

-- tabular preview for csv / json / parquet / xlsx / db
require("duckdb"):setup { mode = "summarized", cache_size = 500 }

-- gvfs/gio mounts, same backend as Nautilus: USB, LUKS, MTP, SMB
require("gvfs"):setup { input_position = { "center", y = 0, w = 60 } }
