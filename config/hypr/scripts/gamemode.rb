#!/usr/bin/env ruby
animations_enabled=`hyprctl getoption animations:enabled | awk 'NR==1{print $2}'`.chomp()

puts animations_enabled
if animations_enabled == "true"
  `hyprctl eval "
    hl.config({
      general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 0,
      },
      animations = {
        enabled = false
      },
      decoration = {
        drop_shadow = 0,
        rounding = 0,
        blur = {
          enabled = false
        }
      }})"`
  `notify-send "Game mode enabled"`
else
  `hyprctl reload`
  `notify-send "Game mode disabled"`
end
