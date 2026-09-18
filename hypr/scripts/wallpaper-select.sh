#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

SELECTED=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec basename {} \; | wofi --show dmenu --prompt "Wallpaper:")

if [ -n "$SELECTED" ]; then
    FULL_PATH="$WALLPAPER_DIR/$SELECTED"
    hyprctl hyprpaper preload "$FULL_PATH"
    hyprctl hyprpaper wallpaper ",$FULL_PATH"
fi
