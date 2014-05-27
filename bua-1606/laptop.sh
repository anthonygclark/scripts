#!/bin/sh
xrandr --output DP3 --off --output DP2 --off --output DP1 --off --output HDMI3 --off --output HDMI2 --off --output HDMI1 --off --output LVDS1 --mode 1366x768 --pos 0x0 --rotate normal --output VGA1 --off & disown
export Y=1
$(sleep 2 ; killall dzen2 ; dzen.sh) & disown
