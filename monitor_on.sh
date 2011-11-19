#!/bin/bash

xrandr --output VGA1 --mode 1024x768 --same-as LVDS1
notify-send -t 1 --icon=~/.icons/elementary/devices/32/computer.svg "Turning On" "VGA1"
