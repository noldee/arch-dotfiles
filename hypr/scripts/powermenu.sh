#!/usr/bin/env bash

# Opciones con iconos
op_poweroff="󰐥  Shutdown"
op_reboot="󰜉  Reboot"
op_suspend="󰤄  Suspend"
op_logout="󰍃  Logout"
op_lock="󰌾  Lock"

# Generar lista de opciones usando Rofi con el tema personalizado
chosen=$(printf "$op_poweroff\n$op_reboot\n$op_suspend\n$op_logout\n$op_lock" | rofi -dmenu -i -theme ~/.config/rofi/powermenu.rasi)

case "$chosen" in
    "$op_poweroff")
        systemctl poweroff
        ;;
    "$op_reboot")
        systemctl reboot
        ;;
    "$op_suspend")
        hyprlock &
        sleep 1
        systemctl suspend
        ;;
    "$op_logout")
        hyprctl dispatch exit
        ;;
    "$op_lock")
        hyprlock
        ;;
esac
