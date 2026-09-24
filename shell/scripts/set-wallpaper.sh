#!/usr/bin/env bash
# Sets the shell wallpaper. Without --image it asks for one in a file dialog.
# With --theme it also rebuilds the palette from the image.
set -euo pipefail

image=""
theme=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --image) image=$2; shift 2 ;;
        --theme) theme=true; shift ;;
        *) echo "Unknown option $1" >&2; exit 1 ;;
    esac
done

if [[ -z $image ]]; then
    image=$(zenity --file-selection --title="Choose wallpaper" \
        --file-filter="Images | *.jpg *.jpeg *.png *.webp *.avif *.bmp") || exit 0
fi

config=${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/config.json
[[ -s $config ]] || echo '{}' > "$config"
jq --arg path "$image" '.background.wallpaperPath = $path' "$config" > "$config.new"
mv "$config.new" "$config"

if $theme; then
    "${XDG_CONFIG_HOME:-$HOME/.config}/theme/from-wallpaper" "$image"
fi
