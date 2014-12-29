#!/bin/bash
EnvY=$Y
EnvIFACE=$IFACE

source $(dirname $(readlink -f $0))/../dzen_common.sh

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
UP_ICON="UP"
DOWN_ICON="DWN"
WIRELESS_ICON="WIFI"
CLOCK_FORMAT="%I:%M %A %D"

IFACE=${EnvIFACE:-"lo"}

# Find the width of the attached monitors
# and set X (x-offset) to the correct right corner-width
__arr=($(xdpyinfo | grep dimensions))
X=$(cut -dx -f1 <<< ${__arr[1]})
X=$(bc <<< $X-$WIDTH)
Y=${EnvY:-0}

# redefine icon() since we arent using xpm icons
function icon() 
{
	echo "^fg($ICON_COLOR)$1^fg()"
}

while :; do
	battery  ; print_seperator ;
    wireless ; print_seperator ;
    cpu      ; print_seperator ;
    mem      ; print_seperator ;
    hdd '/$' ; print_seperator ;
    volume   ; print_seperator ;
    dbox     ; print_seperator ;
    net      ; print_seperator ;
    clock    ;
    sleep $REFRESH_RATE
done | dzen2 -fg $FG_COLOR -bg $BG_COLOR -ta $TEXT_ALIGNMENT -w $WIDTH -h $HEIGHT -x $X -y $Y -fn $FONT -e ''

# vim: foldmethod=marker : 
