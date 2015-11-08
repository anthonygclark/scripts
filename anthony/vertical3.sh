#!/bin/sh
xrandr --output DVI-D-0 --mode 1920x1200 --pos 0x448 --rotate normal --output HDMI-0 --off --output DVI-I-1 --mode 1920x1200 --pos 1920x0 --rotate left --output DVI-I-0 --off --output DP-1 --off --output DP-0 --off
sleep 2 
killall dzen2
killall dzen.sh
dzen.sh & disown
