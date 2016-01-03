#!/bin/bash
source $(dirname $(readlink -m $0))/../dzen_common.sh

function get_wifi_interface()
{
    echo $(cat /proc/net/wireless | tail -1 | cut -d: -f1)
}

IFACE=$(get_wifi_interface)
CLOCK_FORMAT="%I:%M %A %D"

MUSIC_ICON="${ICON_SRC}/note.xbm"
PLAY_ICON="${ICON_SRC}/play.xbm"
NEXT_ICON="${ICON_SRC}/next.xbm"
PREV_ICON="${ICON_SRC}/prev.xbm"

# override X as I want dzen on my primary monitor
X=1220

function mpd()
{
    echo -n "^ca(1, urxvt -e sh -c ncmpcpp)$(icon $MUSIC_ICON)^ca()"   
    echo -n "^ca(1, mpc prev >/dev/null ; now-playing)  $(icon $PREV_ICON)^ca()"
    echo -n "^ca(1, mpc toggle >/dev/null)  $(icon $PLAY_ICON)^ca()"
    echo -n "^ca(1, mpc next >/dev/null ; now-playing)  $(icon $NEXT_ICON)^ca()"
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
