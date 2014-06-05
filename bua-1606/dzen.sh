#!/bin/bash
EnvY=$Y
. $(dirname $(readlink -f $0))/../dzen_common.sh

# redefining icons
BATTERY_CHARGING_ICON="AC"
BATTERY_DISCHARGING_ICON="BAT"
BATTERY_MISSING_ICON="AC"
WIRELESS_ICON="NET"
VOLUME_ICON="VOL"
HDD_ICON="HDD"
MEM_ICON="MEM"
CPU_ICON="CPU"
EMAIL_ICON="MAIL"
CLOCK_ICON="TIME"
DBOX_ICON="DBOX"
UP_ICON="up"
DOWN_ICON="dwn"
GPU_ICON="TMP"
BRI_ICON="BRI"

CLOCK_FORMAT="%I:%M %A %D"
ICON_SRC="/dev/null"
IFACE=eno1
REFRESH_RATE=3

# Find the width of the attached monitors
# and set X (x-offset) to the correct right corner-width
__arr=($(xdpyinfo | grep dimensions))
X=$(cut -dx -f1 <<< ${__arr[1]})
X=$(bc <<< $X-$WIDTH)

Y=${EnvY:-1}


# redefine icon() since we arent using xpm icons
icon() 
{
	echo "^fg($ICON_COLOR)$1^fg()"
}

# TODO do different things for xbrightness
brightness() 
{
    local CURR=$(bash brightness.sh)
    bar $CURR $BAR_FG_COLOR
}

REFRESH_RATE=4
while :; do
	echo -n "$(battery) $SEP"
    cpu; echo -n "$SEP"
    echo -n "$(icon $MEM_ICON) $(mem_usage) $SEP"
    echo -n "$(icon $HDD_ICON) $(hdd_usage '/$') $SEP" 
	echo -n "$(icon $VOLUME_ICON) $(volume) $SEP"
    dbox; echo -n " $SEP"
    net;  echo -n " $SEP"
    echo "$(clock) "
    sleep $REFRESH_RATE
done | dzen2 -fg $FG_COLOR -bg $BG_COLOR -ta $TEXT_ALIGNMENT -w $WIDTH -h $HEIGHT -x $X -y $Y -fn $FONT -e ''

# vim: foldmethod=marker : 
