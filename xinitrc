#!/bin/sh

# Fix QT Apps
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

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

## MPDSCRIBBLE
#USE_MPDSCRIBBLE=false
#
# mpd
if which mpd &>/dev/null; then
    mpd & 
    if $USE_MPDSCRIBBLE && which mpdscribble &>/dev/null; then
        mpdscribble & 
    fi
fi

# Fix Java Swing
if which wmname &>/dev/null; then
    wmname LG3D
fi

[[ -f ~/.nvidia-settings-rc ]] && nvidia-settings -l & 

# Xresources
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# For gnome services
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# DWM
while true; do
  dbus-launch --exit-with-session dwm >/dev/null 1>&1
done

