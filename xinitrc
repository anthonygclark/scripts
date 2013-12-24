#!/bin/sh

# Fix Java Swing
wmname LG3D

# Fix QT Apps
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Fonts
xset +fp /usr/share/fonts/local
xset fp rehash

# Background
xsetroot -solid grey31

# dzen2
$(sleep 2 ; bash $HOME/code/scripts/dzen_$(hostname).sh) &

# MPD
mpd && mpdscribble &

# DWM
while true; do
  dbus-launch --exit-with-session dwm >/dev/null 1>&1
done
