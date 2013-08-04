#!/bin/bash
. $(readlink -m .)/dzen_common.sh

IFACE=enp3s0

while :; do
    cpu; echo -n "$SEP"
	echo -n "$(icon $MEM_ICON) $(mem_usage) $SEP"
    echo -n "$(icon $HDD_ICON) $(hdd_usage home) $SEP" 
	echo -n "$(icon $VOLUME_ICON) $(volume) $SEP"
    echo -n "$(icon $GPU_ICON) $(nvidia) $SEP"
    net; echo -n " $SEP"
    echo "$(clock) "
	sleep $REFRESH_RATE
done | dzen2 -fg $FG_COLOR -bg $BG_COLOR -ta $TEXT_ALIGNMENT -w $WIDTH -h $HEIGHT -x $X -y $Y -fn $FONT -e ''


# vim: foldmethod=marker : 
