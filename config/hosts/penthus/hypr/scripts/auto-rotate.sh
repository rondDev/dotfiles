#!/usr/bin/env bash

monitor="eDP-1"
finger="wacom-pen-and-multitouch-sensor-finger"
pen="wacom-pen-and-multitouch-sensor-pen"


rotate() {
    local transform="$1"

    hyprctl eval "hl.monitor({
        output = \"$monitor\",
        transform = $transform
    })"
    hyprctl eval "hl.device({
            name = \"$finger\",
            output = \"$monitor\",
            transform = $transform,
    })"
    hyprctl eval "hl.device({
            name = \"$pen\",
            output = \"$monitor\",
            tap_to_click = true,
            transform = $transform,
    })"
}

monitor-sensor | while IFS= read -r line; do
    case "$line" in
        *"normal"*) rotate 0 ;;
        *"bottom-up"*) rotate 2 ;;
        *"left-up"*) rotate 1 ;;
        *"right-up"*) rotate 3 ;;
    esac
done
