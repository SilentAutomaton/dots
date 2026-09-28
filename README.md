# dots

Hyprland, a Quickshell shell and the tools around them, themed from one palette.

## Layout

| Directory | Copied to |
|---|---|
| `hypr/` | `~/.config/hypr` |
| `shell/` | `~/.config/quickshell/shell` |
| `kitty/ foot/ fuzzel/ wlogout/ tmux/ yazi/ glow/ nvim/ btop/ mpv/ fontconfig/ gtk-3.0/ gtk-4.0/` | `~/.config/<same name>` |
| `zsh/environment.d/` | `~/.config/environment.d` |
| `zsh/.zshrc`, `zsh/.zshenv`, `zsh/.sh/` | `~/.zshrc`, `~/.zshenv`, `~/.sh` |
| `theme/` | `~/.config/theme` |

## Install

The configs are copied, not linked, so the repository can move without
breaking the desktop.

```
sudo -A pacman -S --needed - < packages.repo
paru -S --needed $(cat packages.aur)
sudo -A pacman -D --asexplicit $(cat packages.repo packages.aur)

d=$PWD
for app in hypr kitty foot fuzzel wlogout tmux yazi glow nvim btop mpv fontconfig gtk-3.0 gtk-4.0 theme; do
    rsync -a $d/$app/ ~/.config/$app/
done
rsync -a $d/zsh/environment.d/ ~/.config/environment.d/
rsync -a $d/shell/ ~/.config/quickshell/shell/
rsync -a $d/zsh/.sh/ ~/.sh/
cp $d/zsh/.zshrc $d/zsh/.zshenv ~/
[ -e ~/.sh/env.local ] || cp $d/zsh/.sh/env.local.example ~/.sh/env.local   # then fill in the key

~/.config/theme/apply
```

Log out and back in after the first install: Hyprland reads `hyprland.lua`
only at start.

## Saving changes back

Edit the live files, then copy them into the repository before a commit.
Paths stay relative to `~/.config`, so the anchored `.gitignore` patterns keep
plugins, rendered colours and local files out.

```
d=~/proj/code/dots
cd ~/.config
rsync -a --relative --delete --exclude-from=$d/.gitignore \
    hypr kitty foot fuzzel wlogout tmux yazi glow nvim btop mpv fontconfig gtk-3.0 gtk-4.0 theme $d/
cd ~/.config/quickshell && rsync -a --relative --delete shell $d/
cp ~/.zshrc ~/.zshenv $d/zsh/ && rsync -a --exclude env.local ~/.sh/ $d/zsh/.sh/
```

## OpenSnitch

`opensnitch/rules/` hold the vpn-only rules for the agents: each one may leave
only through the interfaces listed in its `000-vpnonly-allow-*` rule, anything
else hits `001-vpnonly-deny-*`. `opensnitch/killswitch/` holds the three rules
that cut the agents off everything but loopback.

The bar button (Settings > Bar > Buttons) and `vpnonly-killswitch on|off|toggle`
arm and disarm the kill switch without a password: sudoers allows exactly the
commands that copy the root-owned rules in, delete them, and close the
connections the agents already hold open (OpenSnitch only judges the first
packet of a TCP connection).

```
sudo -A install -d -m 755 /etc/opensnitchd/killswitch
sudo -A install -m 600 opensnitch/killswitch/*.json /etc/opensnitchd/killswitch/
for f in opensnitch/rules/*.json; do    # one by one, in place: see the note below
    sudo -A tee /etc/opensnitchd/rules/${f##*/} < $f > /dev/null
    sudo -A chmod 600 /etc/opensnitchd/rules/${f##*/}
done
# The allow rules name the tunnels; the bar indicator reads them without root.
sudo -A chmod 644 /etc/opensnitchd/rules/000-vpnonly-allow-*.json
sudo -A install -m 600 opensnitch/default-config.json /etc/opensnitchd/
sudo -A install -m 755 system/bin/vpnonly-cut /usr/local/bin/
sudo -A install -m 440 system/sudoers.d/vpnonly-killswitch /etc/sudoers.d/
sudo -A install -m 440 system/sudoers.d/listening-ports /etc/sudoers.d/
install -m 755 bin/vpnonly-killswitch ~/.local/bin/
sed "s|^file=~/|file=$HOME/|" opensnitch/ui/settings.conf > ~/.config/opensnitch/settings.conf
```

Never replace a rule file that already exists with `install` or `mv`: the daemon
sees the old file deleted, and it removes the rule from disk.

## NVIDIA power

The RTX 2070 powers off while nothing uses it (runtime D3, fine-grained).
Three things make that work:

```
sudo -A install -m 644 system/udev/80-nvidia-pm.rules system/udev/81-dri-names.rules /etc/udev/rules.d/
sudo -A install -m 644 system/modprobe.d/nvidia.conf /etc/modprobe.d/
sudo -A install -m 755 system/bin/start-hyprland-igpu /usr/local/bin/
sudo -A install -D -m 644 system/wayland-sessions/hyprland-igpu.desktop /usr/local/share/wayland-sessions/hyprland-igpu.desktop
sudo -A udevadm control --reload && sudo -A udevadm trigger -s drm -s pci
```

- `80-nvidia-pm.rules` sets `power/control=auto` when the driver binds and
  `on` when it unbinds, so handing the card to vfio-pci still works.
- `81-dri-names.rules` names the Intel card `/dev/dri/intel-igpu`, and
  the "Hyprland (Intel only)" session in GDM runs `start-hyprland-igpu`, which
  gives Hyprland only that card and Mesa's EGL only: NVIDIA's EGL driver opens
  the card as soon as it loads. `hypr/modules/execs.lua` gives launched programs
  both drivers back, so `prime-run` still works. GDM does not pass these
  variables from environment.d, hence the wrapper. Otherwise Hyprland holds
  the NVIDIA card open and it never sleeps.
- Suspend uses the kernel notifiers `nvidia-utils` turns on; the
  nvidia-suspend/resume services stay disabled.

Costs: HDMI and DP-3 are wired to NVIDIA and stay dark while Hyprland runs
on Intel only (pick the plain "Hyprland" session in GDM to use them).
Waking the card takes a fraction of a second, and a card in D3cold may refuse
to come back for a second VFIO start: set `power/control` to `on` before
passthrough.

## Theme

`theme/palettes/*.sh` hold the colours as Material 3 roles plus the sixteen
terminal colours. `~/.config/theme/apply [name]` renders every file in `theme/templates`
to the same path under `$HOME` and reloads Hyprland, kitty, tmux and cava.

`~/.config/theme/from-wallpaper <image> [scheme]` builds `palettes/wallpaper.sh` with
matugen and applies it. `apply tomorrow-night` goes back.

The settings app (Super+I) and the launcher action `/theme <name>` do the same.

## Matrix wallpaper

Settings (Super+I), Appearance, Wallpaper: "Matrix news" runs
matrix-news-viewer in place of the image. Install it
with `cargo install --path . --root ~/.local`. "Refresh news" runs
`newsboat -x reload`; nothing else goes to the network. With `preset = "theme"`
in its config the rain takes the palette colours from `theme.toml`.

## Keys

| Keys | Action |
|---|---|
| Super | Search |
| Super+Tab | Overview |
| Super+D | Fuzzel |
| Super+Return | Kitty |
| Super+F, Super+Shift+F | Yazi, Nautilus |
| Super+B, Super+Shift+B | LibreWolf, Chromium |
| Super+T, Super+J | Telegram, Obsidian |
| Super+Q, Super+Shift+Q | Close window |
| Super+Z, Super+Shift+D | Fullscreen, maximize |
| Super+Shift+Space | Float |
| Super+P | Pin |
| Super+U | Usage sidebar |
| Super+N | Notifications sidebar |
| Super+V | Clipboard |
| Super+M | Media controls |
| Super+Shift+M, Super+Alt+M | Mute output, mute microphone |
| Super+Comma, Super+Period, Super+Shift+P | Previous, next, play/pause |
| Super+media keys | MPD |
| Super+W | Wallpaper |
| Super+I | Settings |
| Super+O | Copy text from a region |
| Print, Super+Print, Super+Shift+Print | Screen, region, Hermes |
| Super+L, Super+Shift+L | Lock, suspend |
| Super+Escape, Ctrl+Alt+Delete | Session menu |
| Ctrl+Super+R | Restart the shell |
| Ctrl+Alt+B | Toggle the bar |
| Ctrl+Shift+Escape | btop |
| Super+1…0, Super+Shift+1…0 | Go to, send to workspace |
| Super+S, Super+Alt+S | Scratchpad, send to scratchpad |
| Super+arrows, Super+Shift+arrows | Focus, move window |
| Super+; and Super+' | Split ratio |
