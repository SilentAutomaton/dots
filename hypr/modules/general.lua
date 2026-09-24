hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.gesture({ fingers = 3, direction = "swipe", action = "move" })
hl.gesture({ fingers = 3, direction = "pinch", action = "float" })
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({
    fingers = 4,
    direction = "up",
    action = function() hl.dispatch(hl.dsp.global("quickshell:overviewWorkspacesToggle")) end,
})
hl.gesture({
    fingers = 4,
    direction = "down",
    action = function() hl.dispatch(hl.dsp.global("quickshell:overviewWorkspacesClose")) end,
})

hl.config({
    gestures = {
        workspace_swipe_distance = 700,
        workspace_swipe_cancel_ratio = 0.2,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new = true,
    },
    general = {
        gaps_in = 4,
        gaps_out = 5,
        gaps_workspaces = 50,
        border_size = 1,
        resize_on_border = true,
        no_focus_fallback = true,
        -- Lets the `immediate` window rule work.
        allow_tearing = true,
        snap = { enabled = true, window_gap = 4, monitor_gap = 5, respect_gaps = true },
    },
    dwindle = { preserve_split = true, smart_split = false, smart_resizing = false },
    decoration = {
        rounding = 18,
        rounding_power = 2,
        -- Sized for the Intel UHD 630 at 144 Hz: a 6.9 ms frame leaves no room for
        -- xray blur, which renders every surface twice.
        blur = {
            enabled = true,
            xray = false,
            special = false,
            new_optimizations = true,
            size = 6,
            passes = 2,
            brightness = 1,
            noise = 0.05,
            contrast = 0.89,
            vibrancy = 0,
            vibrancy_darkness = 0.5,
            popups = false,
            popups_ignorealpha = 0.6,
            input_methods = true,
            input_methods_ignorealpha = 0.8,
        },
        shadow = { enabled = true, range = 50, offset = { 0, 4 }, render_power = 10, color = "rgba(00000027)" },
        dim_inactive = false,
        dim_strength = 0.05,
        dim_special = 0.2,
    },
    animations = { enabled = true },
    input = {
        kb_layout = "us,ru",
        kb_options = "grp:alt_shift_toggle",
        numlock_by_default = true,
        repeat_delay = 250,
        repeat_rate = 35,
        follow_mouse = 1,
        off_window_axis_events = 2,
        special_fallthrough = true,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor = 0.7,
        },
    },
    -- An idle compositor between frames adds cursor lag on this machine.
    debug = { vfr = false },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        enable_anr_dialog = false,
        -- VRR on i915 breaks frame pacing during animations.
        vrr = 0,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        animate_manual_resizes = false,
        animate_mouse_windowdragging = false,
        enable_swallow = false,
        on_focus_under_fullscreen = 2,
        allow_session_lock_restore = true,
        session_lock_xray = true,
        initial_workspace_tracking = false,
        focus_on_activate = true,
    },
    binds = { scroll_event_delay = 0, hide_special_on_workspace_change = true },
    cursor = { no_hardware_cursors = 0, hotspot_padding = 1 },
    xwayland = { force_zero_scaling = true },
})

hl.curve("easeOut", { type = "bezier", points = { { 0.0, 0.0 }, { 0.2, 1.0 } } })

for leaf, style in pairs({
    windowsIn = "popin 100%",
    windowsOut = "popin 100%",
    windowsMove = false,
    fadeIn = false,
    fadeOut = false,
    layersIn = "fade",
    layersOut = "fade",
    fadeLayersIn = false,
    fadeLayersOut = false,
    workspaces = "fade",
    specialWorkspaceIn = "slidefade",
    specialWorkspaceOut = "slidefade",
    border = false,
}) do
    hl.animation({ leaf = leaf, enabled = true, speed = 2, bezier = "easeOut", style = style or nil })
end
