#!/bin/sh
xrandr --output HDMI2 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI1 --off --output DP1 --off --output eDP1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output VIRTUAL1 --off
export IFACE=wlp2s0
sleep 2 
killall dzen2
dzen.sh & disown
