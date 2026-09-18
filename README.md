
## Wallpapers
Only one example wallpaper is included at `wallpapers/example.png`.
Add your own images to `~/Pictures/wallpapers/` (not fully tracked in this repo).
Use `Super + W` to open the wallpaper selector (wofi) and switch between them.

## Pywal (dynamic colors)
This setup uses pywal for dynamic color generation from wallpapers.
After adding your own wallpaper to `~/Pictures/wallpapers/`, run:
\`\`\`
wal -i ~/Pictures/wallpapers/your_image.jpg
\`\`\`
This regenerates colors in `~/.cache/wal/` used by waybar, rofi, and kitty.
