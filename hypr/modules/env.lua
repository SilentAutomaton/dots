local home = os.getenv("HOME")

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XDG_DATA_DIRS", home .. "/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share")

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XDG_MENU_PREFIX", "plasma-")
hl.env("TERMINAL", "kitty -1")
hl.env("PATH", home .. "/.local/bin:" .. os.getenv("PATH"))

-- Intel UHD 630: hardware video decoding in Firefox-based browsers.
hl.env("LIBVA_DRIVER_NAME", "iHD")
hl.env("MOZ_DRM_DEVICE", "/dev/dri/renderD128")
