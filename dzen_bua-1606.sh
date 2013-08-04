#!/bin/bash
REFRESH_RATE=2

# -- Colors
BLACK="#393939"
RED="#da4939"
GREEN="#519f50"
YELLOW="#cc7833"
BLUE="#31658c"
MAGENTA="#9f5079"
CYAN="#435d75"
WHITE="#dddddd"
GRAY="#696969"
LIGHT_GRAY="#333333"
DARK_GRAY="#121212"
MED_GRAY="#2a2a2a"

FG_COLOR=$GRAY
BG_COLOR=$DARK_GRAY
ICON_COLOR=$BLUE
BAR_FG_COLOR=$FG_COLOR
BAR_BG_COLOR=$LIGHT_GRAY
BAR_CRITICAL_COLOR=$RED
BAR_OFF_COLOR=$MED_GRAY
SEPERATOR_COLOR=$MED_GRAY

# -- Font
FONT="-*-cure-medium-r-*-*-12-*-*-*-*-*-*-*"

# -- Macros
SEP="^fg($SEPERATOR_COLOR)| ^fg()"

# -- Sizes / Alignment
WIDTH=600
HEIGHT=13
TEXT_ALIGNMENT="right"
currentScreenWidth=$(xrandr | grep '*' | head -1 | cut -d'x' -f1)

if [ "$TEXT_ALIGNMENT" == "right" ] ; then
  X=$(($currentScreenWidth-$WIDTH))
else
  X=1
fi
Y=1

# -- Icons
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

# -- network
IFACE="eth0"
RXB=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
TXB=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)
 
# -- Formats
CLOCK_FORMAT="%I:%M"

# -- clients

# -- Other
CRITICAL_PERCENTAGE=10
BAR_STYLE="-w 33 -h 7 -o -min 0 -max 101 -nonl"


# -- Helpers {{{
icon() {
	echo "^fg($ICON_COLOR)$1^fg()"
}

bar() {
	echo -n "$1" | dzen2-gdbar $BAR_STYLE -fg "$2" -bg $BAR_BG_COLOR
}
#}}}


# -- Battery {{{
battery_icon() {
	if [ "$battery_status" == "Charging" ]; then
		icon "$BATTERY_CHARGING_ICON"
	elif [ "$battery_status" == "Discharging" ]; then
		icon "$BATTERY_DISCHARGING_ICON"
	else
		icon "$BATTERY_MISSING_ICON"
	fi
}

battery_percentage() {
    percentage=$(acpi -b | cut -d "," -f 2 | tr -d " %")
    if [ -z "$percentage" ]; then
        echo "AC"
    elif [ $percentage -le $CRITICAL_PERCENTAGE ] ; then
        bar "$percentage" $BAR_CRITICAL_COLOR
    else
        bar "$percentage" $BAR_FG_COLOR
    fi
}

battery() {
    battery_status=$(acpi -b | cut -d ' ' -f 3 | tr -d ',')
    echo $(battery_icon) $(battery_percentage)
}
# }}}


# -- Wireless {{{
wireless_quality() {
    quality_bar=$(cat /proc/net/wireless | grep $IFACE | cut -d ' ' -f 6 | tr -d '.')
    if [ -z "$quality_bar" ] ; then
        bar 100 $BAR_OFF_COLOR
    else
        quality_bar=$(printf "%0.0f" $(echo "scale=10;($quality_bar/70)*100" | bc))
        if [ "$quality_bar" -le $CRITICAL_PERCENTAGE ] ; then
            bar $quality_bar $BAR_CRITICAL_COLOR
        else
            bar $quality_bar $BAR_FG_COLOR
        fi
    fi
}
#}}}


# -- Volume {{{
volume() {
	Volume=$(amixer get Master | egrep -o "[0-9]+%" | tr -d "%")
	if [ -z "$(amixer get Master | grep "\[on\]")" ]; then
		echo -n "$(bar $Volume $BAR_OFF_COLOR)"
	else
        echo -n "$(bar $Volume $BAR_FG_COLOR)"
	fi
}
# }}}


# -- Clock {{{
clock() {
	echo "^fg($WHITE)$(date +$CLOCK_FORMAT)^fg()"
}
 #}}}


# -- Nvidia {{{
nvidia() {
    echo $(nvidia-settings -query GPUCoreTemp | perl -ne 'print $1 if /GPUCoreTemp.*?: (\d+)./;')
}
#}}}


# -- Hard disks {{{
hdd_usage() {
    echo $(df | grep "$1" | awk '{print $5}')
}
# }}}


# -- Memory {{{
mem_usage() {
    printf %0.0f%% $(free -t | grep "buffers/cache" | awk '{print ($3*100)/($4)}')
}
#}}}


# -- Network {{{  
net() {
    RXBN=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
    TXBN=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)
    local NEW_RX=$(echo "($RXBN - $RXB) / 1024 / $REFRESH_RATE" | bc)
    local NEW_TX=$(echo "($TXBN - $TXB) / 1024 / $REFRESH_RATE" | bc)
    echo -n "$(icon $DOWN_ICON) ${NEW_RX}kB/s $(icon $UP_ICON) ${NEW_TX}kB/s"
    RXB=$(($RXBN))
    TXB=$(($TXBN))
}
# }}}


# -- CPU {{{
PREV_TOTAL=0
PREV_IDLE=0
cpu() {
    local CPU=(`cat /proc/stat | grep '^cpu '`)
    unset CPU[0]
    local IDLE=${CPU[4]}
    
    # Calculate the total CPU time.
    local TOTAL=0
    for VALUE in "${CPU[@]}"; do
        let "TOTAL=$TOTAL+$VALUE"
    done

    # Calculate the CPU usage since we last checked.
    let "DIFF_IDLE=$IDLE-$PREV_IDLE"
    let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
    let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
    echo -n "$(icon $CPU_ICON) $DIFF_USAGE% "

    PREV_TOTAL=$(($TOTAL))
    PREV_IDLE=$(($IDLE))
}
#}}}


while :; do
	echo -n "$(battery) $SEP"
    #echo -n "$(icon $WIRELESS_ICON) $(wireless_quality) $SEP"
    cpu; echo -n "$SEP"
    echo -n "$(icon $MEM_ICON) $(mem_usage) $SEP"
    echo -n "$(icon $HDD_ICON) $(hdd_usage '/$') $SEP" 
	echo -n "$(icon $VOLUME_ICON) $(volume) $SEP"
    #echo -n "$(icon $GPU_ICON) $(nvidia) $SEP"
    net; echo -n " $SEP"
    echo "$(clock) "
    sleep $REFRESH_RATE
done | dzen2 -fg $FG_COLOR -bg $BG_COLOR -ta $TEXT_ALIGNMENT -w $WIDTH -h $HEIGHT -x $X -y $Y -fn $FONT -e ''


# vim: foldmethod=marker : 
