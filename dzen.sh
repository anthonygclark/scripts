#!/bin/bash
REFRESH_RATE=2

# -- Locations
ICON_SRC="/home/anthony/code/icons"

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
currentScreenWidth=$(xrandr | grep '*' | cut -d'x' -f1)
if [ "$TEXT_ALIGNMENT" == "right" ] ; then
  X=$(($currentScreenWidth-$WIDTH))
else
  X=1
fi
Y=1

# -- Icons
BATTERY_CHARGING_ICON="${ICON_SRC}/ac_01.xbm"
BATTERY_DISCHARGING_ICON="${ICON_SRC}/bat_full_02.xbm"
BATTERY_MISSING_ICON="${ICON_SRC}/ac_01.xbm"
WIRELESS_ICON="${ICON_SRC}/wifi_01.xbm"
VOLUME_ICON="${ICON_SRC}/spkr_01.xbm"
HDD_ICON="${ICON_SRC}/diskette.xbm"
MEM_ICON="${ICON_SRC}/mem.xbm"
EMAIL_ICON="${ICON_SRC}/mail.xbm"
CLOCK_ICON="${ICON_SRC}/clock.xbm"
DBOX_ICON="${ICON_SRC}/dbox.xbm"
UP_ICON="${ICON_SRC}/net_up_03.xbm"
DOWN_ICON="${ICON_SRC}/net_down_03.xbm"
GPU_ICON="${ICON_SRC}/temp.xbm"

# -- network
IFACE=wlan0
RXB=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
TXB=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)
 
# -- Formats
CLOCK_FORMAT="%I:%M"

# -- clients

# -- Other
CRITICAL_PERCENTAGE=10
BAR_STYLE="-w 33 -h 10 -s o -ss 1 -max 101 -sw 1 -nonl"


# -- Helpers {{{
icon() {
	echo "^fg($ICON_COLOR)^i($1)^fg()"
}

bar() {
	echo $1 | gdbar $BAR_STYLE -fg $2 -bg $BAR_BG_COLOR
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
  echo "$percentage"
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
	volume=$(amixer get Master | egrep -o "[0-9]+%" | tr -d "%")
	if [ -z "$(amixer get Master | grep "\[on\]")" ]; then
		echo -n "$(bar $volume $BAR_OFF_COLOR)"
	else
    echo -n "$(bar $volume $BAR_FG_COLOR)"
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
  lsmod | grep nvidia &>/dev/null
  [ "$?" == "1" ] && echo "GPU: OFF" && return
  echo -n "GPU: "
  # what we have to do for optimus 
  which bumblebeed >/dev/null
  if [ "$?" == "0" ] ; then
    echo $(nvidia-settings -query GPUCoreTemp -c :8 | perl -ne 'print $1 if /GPUCoreTemp.*?: (\d+)./;')
  else
    echo $(nvidia-settings -query GPUCoreTemp | perl -ne 'print $1 if /GPUCoreTemp.*?: (\d+)./;')
  fi
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


while :; do
	echo -n "$(battery) $SEP"
	echo -n "$(icon $WIRELESS_ICON) $(wireless_quality) $SEP"
  echo -n "$(icon $HDD_ICON) $(hdd_usage home) $SEP" 
	echo -n "$(icon $MEM_ICON) $(mem_usage) $SEP"
	echo -n "$(icon $VOLUME_ICON) $(volume) $SEP"
  echo -n "$(icon $GPU_ICON) $(nvidia) $SEP"
  net; echo -n " $SEP" #net has to be called without a parent echo command since it modifies globals.
  echo "$(clock) "
	sleep $REFRESH_RATE
done | dzen2 -fg $FG_COLOR -bg $BG_COLOR -ta $TEXT_ALIGNMENT -w $WIDTH -h $HEIGHT -x $X -y $Y -fn $FONT -e ''


# vim: foldmethod=marker : 
