#!/bin/sh
xrandr --output VIRTUAL1 --off --output eDP1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP1 --off --output HDMI2 --off --output HDMI1 --off --output DP1-3 --off --output DP1-2 --off --output DP1-1 --mode 1920x1080 --pos 1920x0 --rotate normal
export Y=1
export IFACE=wlp2s0
sleep 2 
killall dzen2
dzen.sh & disown
