#!/bin/bash
source $(dirname $(readlink -m $0))/../dzen_common.sh

function get_wifi_interface()
{
    local f="$(cat /proc/net/wireless | tail -1 | cut -d: -f1)"

    if [[ "$f" =~ "face" ]] ; then
        echo "lo"
    else
        echo $f
    fi
}

IFACE=$(get_wifi_interface)
CLOCK_FORMAT="%I:%M %A %D"

while :; do
	battery  ; print_seperator ;
    wireless ; print_seperator ;
    cpu      ; print_seperator ;
    mem      ; print_seperator ;
    hdd '/$' ; print_seperator ;
    volume   ; print_seperator ;
	nvidia   ; print_seperator ;
    dbox     ; print_seperator ;
    net      ; print_seperator ;
    clock    ;
	sleep $REFRESH_RATE
done | dzen2 -fg $FG_COLOR -bg $BG_COLOR -ta $TEXT_ALIGNMENT -w $WIDTH -h $HEIGHT -xs 1 -x $X -y $Y -fn $FONT -e ''

# vim: foldmethod=marker : 
