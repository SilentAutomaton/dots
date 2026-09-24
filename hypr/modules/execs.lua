hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c shell")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("pidof -x opensnitch-ui || opensnitch-ui --background")
    hl.exec_cmd("dbus-update-activation-environment --all")
    hl.exec_cmd("sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    hl.exec_cmd("wl-paste --type text --watch bash -c 'cliphist store && qs -c shell ipc call cliphistService update'")
    hl.exec_cmd("wl-paste --type image --watch bash -c 'cliphist store && qs -c shell ipc call cliphistService update'")

    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
end)
