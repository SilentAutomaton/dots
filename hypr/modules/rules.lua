hl.window_rule({ match = { class = ".*" }, no_blur = true })

for _, title in ipairs({
    "^(Open File)(.*)$",
    "^(Select a File)(.*)$",
    "^(Open Folder)(.*)$",
    "^(Save As)(.*)$",
    "^(Library)(.*)$",
    "^(File Upload)(.*)$",
    "^(.*)(wants to save)$",
    "^(.*)(wants to open)$",
}) do
    hl.window_rule({ match = { title = title }, float = true, center = true })
end
hl.window_rule({
    match = { title = "^(Choose wallpaper)(.*)$" },
    float = true,
    center = true,
    size = { "(monitor_w*0.60)", "(monitor_h*0.65)" },
})

for _, class in ipairs({ "^(org.pulseaudio.pavucontrol)$", "^(pavucontrol)$", "^(nm-connection-editor)$" }) do
    hl.window_rule({ match = { class = class }, float = true, center = true, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } })
end
hl.window_rule({ match = { class = "^(vncviewer)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(blueberry\\.py)$" }, float = true })
hl.window_rule({ match = { class = ".*plasmawindowed.*" }, float = true })
hl.window_rule({ match = { class = "kcm_.*" }, float = true })
hl.window_rule({ match = { class = ".*bluedevilwizard" }, float = true })
hl.window_rule({ match = { title = "^(Shell Settings)$" }, float = true })
hl.window_rule({
    match = { class = "org.freedesktop.impl.portal.desktop.kde" },
    float = true,
    size = { "(monitor_w*0.60)", "(monitor_h*0.65)" },
})
hl.window_rule({ match = { title = "^(Copying — Dolphin)$" }, move = { 40, 80 } })

local pip = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
hl.window_rule({
    match = { title = pip },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
    move = { "(monitor_w*0.73)", "(monitor_h*0.72)" },
    size = { "(monitor_w*0.25)", "(monitor_h*0.25)" },
    no_screen_share = true,
})

hl.window_rule({ match = { title = ".*\\.exe" }, immediate = true })
hl.window_rule({ match = { title = ".*minecraft.*" }, immediate = true })
hl.window_rule({ match = { class = "^(steam_app).*" }, immediate = true })
hl.window_rule({
    match = { class = "^jetbrains-.*$", float = true, title = "^$|^\\s$|^win\\d+$" },
    no_initial_focus = true,
})
-- OrcaSlicer's printer error dialogs wait on a hidden workspace; the overlay
-- shows them as cards.
hl.window_rule({
    match = { class = "^(orca-slicer)$", title = "^(Error|Warning|Info|Unknown)$" },
    workspace = "special:orca silent",
    no_initial_focus = true,
    focus_on_activate = false,
})
hl.window_rule({ match = { float = false }, no_shadow = true })

hl.workspace_rule({ workspace = "special:special", gaps_out = 30 })

-- Shell layers stay unblurred so the bar reads as one surface with the terminal.
hl.layer_rule({ match = { namespace = ".*" }, xray = true })
hl.layer_rule({ match = { namespace = "launcher" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })
hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "gtk4-layer-shell" }, no_anim = true })
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
hl.layer_rule({ match = { namespace = "noanim" }, no_anim = true })

for namespace, animation in pairs({
    bar = "slide",
    verticalBar = "slide",
    reloadPopup = "slide",
    sidebarLeft = "slide left",
    sidebarRight = "slide right",
    wallpaperSelector = "slide top",
    screenCorners = "popin 120%",
}) do
    hl.layer_rule({ match = { namespace = "quickshell:" .. namespace }, animation = animation })
end
for _, namespace in ipairs({
    "lockWindowPusher", "overview", "polkit", "regionSelector", "screenshot", "session",
}) do
    hl.layer_rule({ match = { namespace = "quickshell:" .. namespace }, no_anim = true })
end
hl.layer_rule({ match = { namespace = "quickshell:popup" }, xray = false, ignore_alpha = 1 })
hl.layer_rule({ match = { namespace = "quickshell:mediaControls" }, ignore_alpha = 1 })
-- The overlay stays out of screen capture: a black box without the overlay's
-- Hyprland plugin, nothing at all with it. The plugin is built from the
-- overlay repository and must match this Hyprland build. It hides the
-- Picture-in-Picture window above the same way.
hl.layer_rule({ match = { namespace = "overlay:.*" }, no_screen_share = true })
local overlay_hide = os.getenv("HOME") .. "/.local/lib/hyprland/overlay-hide.so"
local plugin = io.open(overlay_hide)
if plugin then
    plugin:close()
    hl.plugin.load(overlay_hide)
end
hl.layer_rule({ match = { namespace = "overlay:stack" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "overlay:details" }, no_anim = true })
