local home = os.getenv("HOME")

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XDG_DATA_DIRS", home .. "/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share")

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XDG_MENU_PREFIX", "plasma-")
hl.env("TERMINAL", "kitty -1")

-- Intel UHD 630: hardware video decoding in Firefox-based browsers.
hl.env("LIBVA_DRIVER_NAME", "iHD")
hl.env("MOZ_DRM_DEVICE", "/dev/dri/renderD128")

-- Hyprland opens every GPU it finds, which keeps the NVIDIA card awake for the
-- whole session. Only the Intel card drives the screens; games and CUDA still
-- reach NVIDIA through prime-run. HDMI and DP-3 are wired to NVIDIA, so they
-- stay dark: drop this line to use an external monitor.
hl.env("AQ_DRM_DEVICES", "/dev/dri/intel-igpu")
