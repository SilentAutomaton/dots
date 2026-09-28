-- Letters follow a mnemonic: U usage, N notifications, V paste, M media,
-- W wallpaper, A answer a firewall prompt, O OCR, L lock, R reload. Number
-- keys use keycodes, so the binds keep working under the Russian layout.

local function shell(name)
    return hl.dsp.global("quickshell:" .. name)
end

local function exec(cmd)
    return hl.dsp.exec_cmd(cmd)
end

local function workspace_in_group(i)
    local current = hl.get_active_workspace().id
    return math.floor((current - 1) / 10) * 10 + i
end

local screenshots = "$HOME/pix/Screenshots"
local stamp = "$(date '+%Y-%m-%d_%H.%M.%S')"

-- Shell
hl.bind("SUPER + SUPER_L", shell("searchToggleRelease"))
hl.bind("SUPER + SUPER_R", shell("searchToggleRelease"))
for _, key in ipairs({ "SUPER_L", "SUPER_R" }) do
    hl.bind(key, shell("workspaceNumber"), { ignore_mods = true, transparent = true })
    hl.bind(key, shell("workspaceNumber"), { ignore_mods = true, transparent = true, release = true })
end
hl.bind("SUPER + Tab", shell("overviewWorkspacesToggle"))
hl.bind("SUPER + V", shell("overviewClipboardToggle"))
hl.bind("SUPER + U", shell("sidebarLeftToggle"))
hl.bind("SUPER + N", shell("sidebarRightToggle"))
hl.bind("SUPER + A", shell("firewallAllow"))
hl.bind("SUPER + SHIFT + A", shell("firewallDeny"))
hl.bind("SUPER + ALT + A", shell("firewallDetails"))
hl.bind("SUPER + M", shell("mediaControlsToggle"))
hl.bind("SUPER + W", shell("wallpaperSelectorToggle"))
hl.bind("SUPER + Escape", shell("sessionToggle"))
hl.bind("CTRL + ALT + Delete", shell("sessionToggle"))
hl.bind("CTRL + ALT + B", shell("barToggle"))
hl.bind("CTRL + SUPER + R", exec("killall qs quickshell; qs -c shell &"))
hl.bind("SUPER + I", exec("qs -p $HOME/.config/quickshell/shell/settings.qml"))

-- Screen capture
hl.bind("Print", exec("mkdir -p " .. screenshots .. " && grim " .. screenshots .. "/Screenshot_" .. stamp .. ".png"),
    { locked = true, non_consuming = true })
hl.bind("Print", exec("grim - | wl-copy"), { locked = true, non_consuming = true })
hl.bind("SUPER + Print", shell("regionScreenshot"))
hl.bind("SUPER + O", shell("regionOcr"))
hl.bind("SUPER + SHIFT + Print", exec("$HOME/.local/bin/hermes-screen"))

-- Brightness and sound
hl.bind("XF86MonBrightnessUp", exec("qs -c shell ipc call brightness increment || brightnessctl s 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", exec("qs -c shell ipc call brightness decrement || brightnessctl s 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.5"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_SINK@ toggle"), { locked = true })
hl.bind("SUPER + SHIFT + M", exec("wpctl set-mute @DEFAULT_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("SUPER + ALT + M", exec("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })

-- Media: playerctl drives the focused player, Super on the media keys drives MPD.
hl.bind("XF86AudioPlay", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", exec("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", exec("playerctl previous"), { locked = true })
hl.bind("SUPER + SHIFT + P", exec("playerctl play-pause"), { locked = true })
hl.bind("SUPER + Period", exec("playerctl next"), { locked = true })
hl.bind("SUPER + Comma", exec("playerctl previous"), { locked = true })
hl.bind("SUPER + XF86AudioPlay", exec("mpc toggle"), { locked = true })
hl.bind("SUPER + XF86AudioNext", exec("mpc next"), { locked = true })
hl.bind("SUPER + XF86AudioPrev", exec("mpc prev"), { locked = true })

-- Windows
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:274", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
for key, direction in pairs({ Left = "l", Right = "r", Up = "u", Down = "d" }) do
    hl.bind("SUPER + " .. key, hl.dsp.focus({ direction = direction }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + ALT + Q", exec("hyprctl kill"))
hl.bind("SUPER + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + Z", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind("SUPER + SHIFT + D", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind("SUPER + P", hl.dsp.window.pin())
hl.bind("SUPER + Semicolon", hl.dsp.layout("splitratio -0.1"), { repeating = true })
hl.bind("SUPER + Apostrophe", hl.dsp.layout("splitratio +0.1"), { repeating = true })

-- Workspaces, in groups of ten
for i = 1, 10 do
    local key = "code:" .. (9 + i)
    hl.bind("SUPER + " .. key, function()
        hl.dispatch(hl.dsp.focus({ workspace = workspace_in_group(i) }))
    end)
    hl.bind("SUPER + SHIFT + " .. key, function()
        hl.dispatch(hl.dsp.window.move({ workspace = workspace_in_group(i), follow = false }))
    end)
end
hl.bind("CTRL + SUPER + Left", hl.dsp.focus({ workspace = "r-1" }))
hl.bind("CTRL + SUPER + Right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("SUPER + Page_Up", hl.dsp.focus({ workspace = "r-1" }))
hl.bind("SUPER + Page_Down", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "+1" }))
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + SHIFT + Page_Up", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind("SUPER + SHIFT + Page_Down", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("special"))
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:special", follow = false }))

-- Session
hl.bind("SUPER + L", exec("loginctl lock-session"))
hl.bind("SUPER + SHIFT + L", exec("systemctl suspend || loginctl suspend"), { locked = true })

-- Apps
hl.bind("SUPER + Return", exec("kitty -1"))
hl.bind("SUPER + D", exec("pkill fuzzel || fuzzel"))
hl.bind("SUPER + F", exec("kitty -1 --class yazi -e yazi"))
hl.bind("SUPER + SHIFT + F", exec("nautilus --new-window"))
hl.bind("SUPER + B", exec("librewolf"))
hl.bind("SUPER + SHIFT + B", exec("ungoogled-chromium"))
hl.bind("SUPER + T", exec("/usr/local/bin/telegram"))
hl.bind("SUPER + J", exec("obsidian"))
hl.bind("CTRL + SHIFT + Escape", exec("kitty -1 btop"))

-- Discord overlay, by keycode for the Russian layout
hl.bind("SUPER + code:49", exec("discord-overlay toggle"))
