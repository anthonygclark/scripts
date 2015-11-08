#!/bin/sh
xrandr --output HDMI-0 --off --output DVI-I-1 --off --output DVI-I-0 --mode 1280x800 --pos 1920x144 --rotate normal --output DVI-I-3 --mode 1920x1080 --pos 0x0 --rotate normal --output DVI-I-2 --off
sleep 2 
killall dzen.sh
killall dzen2
dzen.sh & disown
