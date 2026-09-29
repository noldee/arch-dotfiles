#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
ROFI_THEME="$HOME/.config/rofi/wallselect.rasi"


# ─────────────────────────────────────────────
# Check wallpaper directory
# ─────────────────────────────────────────────

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    notify-send \
        "Wallpaper Selector" \
        "El directorio $WALLPAPER_DIR no existe."
    exit 1
fi

mkdir -p "$CACHE_DIR"


# ─────────────────────────────────────────────
# Build Rofi menu
# ─────────────────────────────────────────────

ROFI_INPUT=""

while IFS= read -r -d '' img; do
    name=$(basename "$img")
    thumb="$CACHE_DIR/${name}.png"

    if [[ ! -f "$thumb" ]]; then
        magick "$img" \
            -thumbnail 120x120^ \
            -gravity center \
            -extent 120x120 \
            "$thumb" 2>/dev/null || \
        ffmpeg \
            -i "$img" \
            -vf "scale=120:120:force_original_aspect_ratio=increase,crop=120:120" \
            "$thumb" \
            -y &>/dev/null || \
        thumb="$img"
    fi

    ROFI_INPUT+="${name}\x00icon\x1f${thumb}\n"

done < <(
    find "$WALLPAPER_DIR" \
        -type f \
        \( \
            -iname "*.jpg" \
            -o -iname "*.jpeg" \
            -o -iname "*.png" \
            -o -iname "*.webp" \
        \) \
        -print0
)


# ─────────────────────────────────────────────
# Show Rofi
# ─────────────────────────────────────────────

ROFI_CMD=(
    rofi
    -dmenu
    -i
    -p "󰸉 Wallpapers"
    -show-icons
)

if [[ -f "$ROFI_THEME" ]]; then
    ROFI_CMD+=(
        -theme "$ROFI_THEME"
    )
fi

SELECTED=$(printf "%b" "$ROFI_INPUT" | "${ROFI_CMD[@]}")

[[ -z "$SELECTED" ]] && exit 0


# ─────────────────────────────────────────────
# Validate selected wallpaper
# ─────────────────────────────────────────────

FULL_PATH="$WALLPAPER_DIR/$SELECTED"

if [[ ! -f "$FULL_PATH" ]]; then
    notify-send \
        "Wallpaper Selector" \
        "Archivo no encontrado: $FULL_PATH"
    exit 1
fi


# ─────────────────────────────────────────────
# Detect wallpaper daemon
# ─────────────────────────────────────────────

if command -v swww &>/dev/null; then
    SW_CMD="swww"
    SW_DAEMON="swww-daemon"

elif command -v awww &>/dev/null; then
    SW_CMD="awww"
    SW_DAEMON="awww-daemon"

else
    notify-send \
        "Wallpaper Selector" \
        "No se encontró swww ni awww."
    exit 1
fi


# ─────────────────────────────────────────────
# Start wallpaper daemon if necessary
# ─────────────────────────────────────────────

if ! pgrep -x "$SW_DAEMON" >/dev/null; then
    "$SW_DAEMON" >/dev/null 2>&1 &
    sleep 0.3
fi


# ─────────────────────────────────────────────
# Apply wallpaper
# ─────────────────────────────────────────────

"$SW_CMD" img "$FULL_PATH" \
    --transition-type center \
    --transition-step 90 \
    --transition-fps 60 \
    --transition-duration 1.5


# ─────────────────────────────────────────────
# Generate Pywal colors
# ─────────────────────────────────────────────

wal -i "$FULL_PATH" -n


# ─────────────────────────────────────────────
# Reload Waybar
# ─────────────────────────────────────────────

pkill -x waybar 2>/dev/null

waybar >/dev/null 2>&1 &


# ─────────────────────────────────────────────
# Reload Hyprland
# ─────────────────────────────────────────────

hyprctl reload >/dev/null 2>&1
