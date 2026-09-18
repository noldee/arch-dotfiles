#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Selector" "The directory $WALLPAPER_DIR does not exist."
    exit 1
fi

mkdir -p "$CACHE_DIR"

# Construcción correcta del menú de Rofi con miniaturas
ROFI_INPUT=""
while IFS= read -r img; do
    name=$(basename "$img")
    thumb="$CACHE_DIR/${name}.png"

    if [ ! -f "$thumb" ]; then
        magick "$img" -thumbnail 120x120^ -gravity center -extent 120x120 "$thumb" 2>/dev/null || \
        ffmpeg -i "$img" -vf "scale=120:120:force_original_aspect_ratio=increase,crop=120:120" "$thumb" -y &>/dev/null || \
        thumb="$img"
    fi

    # Usamos formato literal para que Rofi interprete el icono
    ROFI_INPUT+="${name}\x00icon\x1f${thumb}\n"
done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \))

# Abrir Rofi pasando la cadena con printf para procesar los nulos (\x00)
SELECTED=$(printf "%b" "$ROFI_INPUT" | rofi -dmenu \
    -i \
    -p "󰸉 Wallpapers" \
    -show-icons \
    -theme ~/.config/rofi/wallselect.rasi)

if [ -n "$SELECTED" ]; then
    FULL_PATH="$WALLPAPER_DIR/$SELECTED"

    if ! pgrep -x "awww-daemon" > /dev/null; then
        awww-daemon &
        sleep 0.2
    fi

    # 1. Aplicar animación del fondo
    awww img "$FULL_PATH" \
        --transition-type center \
        --transition-step 90 \
        --transition-fps 60 \
        --transition-duration 1.5

    # 2. Generar paleta de Pywal
    wal -i "$FULL_PATH" -n

    # 3. Recargar Waybar
    pkill waybar && waybar &
fi
