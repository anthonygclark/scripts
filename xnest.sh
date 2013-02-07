#!/bin/sh

[ -z $1 ] && {
    echo "Provide WM/DE to run. e.g - openbox-session"
    exit 1
}

Xnest :1 -name "Xnest" -geometry 1024x768 &
DISPLAY=:1
sleep 1
xsetroot -display :1 -solid "#4f4f4f" &
exec $1
