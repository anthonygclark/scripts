#!/bin/bash
. $(dirname $(readlink -m $0))/dzen_common.sh

IFACE=enp2s0
CLOCK_FORMAT="%I:%M %A %D"

MUSIC_ICON="${ICON_SRC}/note.xbm"
PLAY_ICON="${ICON_SRC}/play.xbm"
NEXT_ICON="${ICON_SRC}/next.xbm"
PREV_ICON="${ICON_SRC}/prev.xbm"

WIDTH=680
X=$(bc <<< 1280-$WIDTH)

function mpd()
{
    echo -n "^ca(1, /home/anthony/code/scripts/music.sh)$(icon $MUSIC_ICON)^ca()"   
    echo -n "^ca(1, mpc prev >/dev/null)  $(icon $PREV_ICON)^ca()"
    echo -n "^ca(1, mpc toggle >/dev/null)  $(icon $PLAY_ICON)^ca()"
    echo -n "^ca(1, mpc next >/dev/null)  $(icon $NEXT_ICON)^ca()"
}

while :; do
    cpu; echo -n "$SEP"
	echo -n "$(icon $MEM_ICON) $(mem_usage) $SEP"
    echo -n "$(icon $HDD_ICON) $(hdd_usage home) $SEP" 
	echo -n "$(icon $VOLUME_ICON) $(volume) $SEP"
    echo -n "$(icon $GPU_ICON) $(nvidia) $SEP"
    dbox; echo -n " $SEP"
    net;  echo -n " $SEP"
    echo -n "$(mpd) $SEP"
    echo "$(clock) "
	sleep $REFRESH_RATE
done | dzen2 -fg $FG_COLOR -bg $BG_COLOR -ta $TEXT_ALIGNMENT -w $WIDTH -h $HEIGHT -xs 1 -x $X -y $Y -fn $FONT -e ''


# vim: foldmethod=marker : 
