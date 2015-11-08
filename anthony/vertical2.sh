#!/bin/sh
xrandr --output DVI-D-0 --mode 1920x1200 --pos 0x0 --rotate left --output HDMI-0 --off --output DVI-I-1 --off --output DVI-I-0 --mode 1920x1200 --pos 1200x384 --rotate normal --output DP-1 --off --output DP-0 --off
sleep 2 
killall dzen2
killall dzen.sh
dzen.sh & disown
