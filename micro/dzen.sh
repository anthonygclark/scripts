#!/bin/bash
EnvY=$Y
EnvIFACE=wlp2s0

source $(dirname $(readlink -f $0))/../dzen_common.sh
CLOCK_FORMAT="%I:%M %A %D"

FONT="-*-dina-*-*-normal-*-9-*-*-*-*-*-*-*"
#FONT="-*-lime-medium-r-*-*-8-*-*-*-*-*-*-*"
IFACE=${EnvIFACE:-"lo"}

# Find the width of the attached monitors
# and set X (x-offset) to the correct right corner-width
__arr=($(xdpyinfo | grep dimensions))
X=$(cut -dx -f1 <<< ${__arr[1]})
X=$(bc <<< $X-$WIDTH)
Y=${EnvY:-0}

while :; do
	battery  ; print_seperator ;
    wireless ; print_seperator ;
    cpu      ; print_seperator ;
    mem      ; print_seperator ;
    hdd '/home' ; print_seperator ;
    net      ; print_seperator ;
    clock    ;
    sleep $REFRESH_RATE
done | dzen2 -fg $FG_COLOR -bg $BG_COLOR -ta $TEXT_ALIGNMENT -w $WIDTH -h $HEIGHT -x $X -y $Y -fn $FONT -e ''

 vim: foldmethod=marker : 
