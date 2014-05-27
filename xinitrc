#!/bin/sh

# Fix QT Apps
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
#/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Fonts
xset +fp /usr/share/fonts/local
xset fp rehash

# Background
xsetroot -solid grey31

# dzen2
DZEN="$HOME/code/scripts/$(hostname)/dzen.sh"
if which $DZEN &>/dev/null; then
    $(sleep 2 ; bash $DZEN) &
fi

# MPD
if which mpd &>/dev/null; then 
    mpd && mpdscribble &
fi

# Fix Java Swing
wmname LG3D

# Xresources
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# DWM
while true; do
  dbus-launch --exit-with-session dwm >/dev/null 1>&1
done

