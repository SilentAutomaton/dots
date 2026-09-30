hl.on("hyprland.start", function()
    -- start-hyprland-igpu hides NVIDIA's EGL driver so Hyprland leaves the card
    -- asleep. The renderer is up by now, so programs launched from here on get
    -- both drivers back and prime-run still works. Set earlier, in env.lua, it
    -- would reach Hyprland itself: the config is read before EGL starts.
    hl.env("__EGL_VENDOR_LIBRARY_FILENAMES", "/usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/50_mesa.json")
    hl.exec_cmd("qs -c shell")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("hypridle")
    -- Takes the daemon's socket and relays everything but the prompts to opensnitch-ui.
    hl.exec_cmd("pidof -x snitch-prompt || $HOME/.local/bin/snitch-prompt")
    -- Turns OrcaSlicer's modal dialogs into cards over AT-SPI.
    hl.exec_cmd("pidof -x orca-watch || $HOME/.local/bin/orca-watch")
    hl.exec_cmd("pidof -x opensnitch-ui || opensnitch-ui --background")
    hl.exec_cmd("dbus-update-activation-environment --all")
    hl.exec_cmd("sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("easyeffects --service-mode")

    hl.exec_cmd("wl-paste --type text --watch bash -c 'cliphist store && qs -c shell ipc call cliphistService update'")
    hl.exec_cmd("wl-paste --type image --watch bash -c 'cliphist store && qs -c shell ipc call cliphistService update'")

    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
end)
