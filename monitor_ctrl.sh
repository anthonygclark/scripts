#!/bin/bash
[ $# -lt 1 ] && echo "Supply mode, e.g. - 1024x768" && exit 1
[ $1 == "--off" ] && echo "Turning off" && xrandr --output VGA1 --off && exit 0
xrandr --output VGA1 --mode $1 --same-as LVDS1
