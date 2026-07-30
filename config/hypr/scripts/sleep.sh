#!/usr/bin/env bash
# needs pacman -S swayidle
#
# save it as ~/.config/hypr/scripts/sleep.sh
# then add:
# exec-once =  $HOME/.config/hypr/scripts/sleep.sh
# to:
# ~/.config/hypr/configs/exec.conf (or whatever, depending on your main hypr configuration ...)
#
# the script does the following:
# 1. turn off monitor/s after 60 sec
# 2. sleep after 120 sec
# 3. lock before sleep
# swayidle -w \
#     timeout 60 'hyprctl dispatch dpms off ' \
#     timeout 120 'systemctl suspend' \
#     resume 'hyprctl dispatch dpms on' \
#     before-sleep 'swaylock'

swayidle -w \
    timeout 300 'systemctl suspend' \
    before-sleep 'swaylock -c 2d2d2d'
