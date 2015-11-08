#!/bin/bash
source $(dirname $(readlink -m $0))/../dzen_common.sh

#IFACE=enp3s0
IFACE=wlp0s29u1u1
CLOCK_FORMAT="%I:%M %A %D"

MUSIC_ICON="${ICON_SRC}/note.xbm"
PLAY_ICON="${ICON_SRC}/play.xbm"
NEXT_ICON="${ICON_SRC}/next.xbm"
PREV_ICON="${ICON_SRC}/prev.xbm"

WIDTH=680
X=$(bc <<< 1920-$WIDTH)

function mpd()
{
    echo -n "^ca(1, urxvt -e sh -c ncmpcpp)$(icon $MUSIC_ICON)^ca()"   
    echo -n "^ca(1, mpc prev >/dev/null)  $(icon $PREV_ICON)^ca()"
    echo -n "^ca(1, mpc toggle >/dev/null)  $(icon $PLAY_ICON)^ca()"
    echo -n "^ca(1, mpc next >/dev/null)  $(icon $NEXT_ICON)^ca()"
}

while :; do
    cpu      ; print_seperator ;
    mem      ; print_seperator ;
    hdd '/$' ; print_seperator ;
    volume   ; print_seperator ;
	nvidia   ; print_seperator ;
    dbox     ; print_seperator ;
    net      ; print_seperator ;
    mpd      ; print_seperator ;
    clock    ;
	sleep $REFRESH_RATE
done | dzen2 -fg $FG_COLOR -bg $BG_COLOR -ta $TEXT_ALIGNMENT -w $WIDTH -h $HEIGHT -xs 1 -x $X -y $Y -fn $FONT -e ''


# vim: foldmethod=marker : 
