#!/bin/bash
. $(readlink -m .)/dzen_common.sh

# redefining icons
BATTERY_CHARGING_ICON="[AC]"
BATTERY_DISCHARGING_ICON="[BAT]"
BATTERY_MISSING_ICON="[AC]"
WIRELESS_ICON="[NET]"
VOLUME_ICON="[VOL]"
HDD_ICON="[HDD]"
MEM_ICON="[MEM]"
CPU_ICON="[CPU]"
EMAIL_ICON="[MAIL]"
CLOCK_ICON="[TIME]"
DBOX_ICON="[DBOX]"
UP_ICON="[u]"
DOWN_ICON="[d]"
GPU_ICON="[TMP]"

ICON_SRC="/dev/null"
IFACE=eth0

BAR_EXEC=dzen2-gdbar
BAR_STYLE="-w 33 -h 7 -o -min 0 -max 101 -nonl"

# redefine icon() since we arent using xpm icons
icon() {
	echo "^fg($ICON_COLOR)$1^fg()"
}

while :; do
	echo -n "$(battery) $SEP"
    cpu; echo -n "$SEP"
    echo -n "$(icon $MEM_ICON) $(mem_usage) $SEP"
    echo -n "$(icon $HDD_ICON) $(hdd_usage '/$') $SEP" 
	echo -n "$(icon $VOLUME_ICON) $(volume) $SEP"
    net; echo -n " $SEP"
    echo "$(clock) "
    sleep $REFRESH_RATE
done | dzen2 -fg $FG_COLOR -bg $BG_COLOR -ta $TEXT_ALIGNMENT -w $WIDTH -h $HEIGHT -x $X -y $Y -fn $FONT -e ''

# vim: foldmethod=marker : 
