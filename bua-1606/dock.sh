#!/bin/sh
xrandr --output DP3 --off --output DP2 --mode 1920x1200 --pos 1920x0 --rotate normal --output DP1 --off --output HDMI3 --mode 1920x1200 --pos 0x0 --rotate normal --output HDMI2 --off --output HDMI1 --off --output LVDS1 --off --output VGA1 --off
$(sleep 2 ; killall dzen2 ; dzen.sh) & disown
