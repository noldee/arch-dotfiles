#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
ROFI_THEME="$HOME/.config/rofi/wallselect.rasi"

# 1. Comprobar que existe la carpeta de fondos
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Selector" "El directorio $WALLPAPER_DIR no existe."
    exit 1
fi

mkdir -p "$CACHE_DIR"

# 2. Generar el menú para Rofi
ROFI_INPUT=""
while IFS= read -r -d '' img; do
    name=$(basename "$img")
    thumb="$CACHE_DIR/${name}.png"

    # Generar miniatura si no existe
    if [ ! -f "$thumb" ]; then
        magick "$img" -thumbnail 120x120^ -gravity center -extent 120x120 "$thumb" 2>/dev/null || \
        ffmpeg -i "$img" -vf "scale=120:120:force_original_aspect_ratio=increase,crop=120:120" "$thumb" -y &>/dev/null || \
        thumb="$img"
    fi

    ROFI_INPUT+="${name}\x00icon\x1f${thumb}\n"
done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0)

# 3. Mostrar menú en Rofi
ROFI_CMD=(rofi -dmenu -i -p "󰸉 Wallpapers" -show-icons)
if [ -f "$ROFI_THEME" ]; then
    ROFI_CMD+=(-theme "$ROFI_THEME")
fi

SELECTED=$(printf "%b" "$ROFI_INPUT" | "${ROFI_CMD[@]}")

# Verificar si se seleccionó algo
if [ -n "$SELECTED" ]; then
    FULL_PATH="$WALLPAPER_DIR/$SELECTED"

    if [ ! -f "$FULL_PATH" ]; then
        notify-send "Wallpaper Selector" "Archivo no encontrado: $FULL_PATH"
        exit 1
    fi

    # 4. Control de demonio de fondo (Detecta 'swww' o 'awww')
    SW_CMD="swww"
    SW_DAEMON="swww-daemon"

    if ! command -v swww &>/dev/null && command -v awww &>/dev/null; then
        SW_CMD="awww"
        SW_DAEMON="awww-daemon"
    fi

    if ! pgrep -x "$SW_DAEMON" > /dev/null; then
        "$SW_DAEMON" &
        sleep 0.3
    fi

    # Aplicar wallpaper
    "$SW_CMD" img "$FULL_PATH" \
        --transition-type center \
        --transition-step 90 \
        --transition-fps 60 \
        --transition-duration 1.5

    # 5. Generar colores con Pywal
    wal -i "$FULL_PATH" -n

    # 6. Recargar Waybar
    pkill -x waybar
    waybar &>/dev/null &

    # 7. Recargar colores en terminales
    pkill -USR1 -x kitty 2>/dev/null
    pkill -USR1 -x foot 2>/dev/null

    # 8. Recargar Hyprland
    hyprctl reload
fi
