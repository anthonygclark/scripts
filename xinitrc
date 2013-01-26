#!/bin/sh

# Fix QT Apps
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Fonts
xset +fp /usr/share/fonts/local/
xset +fp /usr/share/fonts/artwiz-fonts/ 
xset fp rehash

# Background
feh --bg-center /home/anthony/code/scripts/pixels-fit.png &

# dzen2
sleep 2
sh /home/anthony/code/scripts/dzen.sh &

# DWM
while true; do
  dbus-launch --exit-with-session dwm >/dev/null 1>&1
done
