# Remember that functions that modify variables outside
# their scope cannot be called in a subshell. ie - 
# you cannot do `echo myf` if myf modifies vars outside
# itself.
REFRESH_RATE=2

# -- Locations
ICON_SRC="$HOME/.icons/dzen"

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

FONT="-*-cure-medium-r-*-*-12-*-*-*-*-*-*-*"
SEP="^fg($SEPERATOR_COLOR)| ^fg()"

WIDTH=700
HEIGHT=13
TEXT_ALIGNMENT="right"

# Find the width of the attached monitors
# and set X (x-offset) to the correct right corner-width
__arr=($(xdpyinfo | grep dimensions))
X=$(cut -dx -f1 <<< ${__arr[1]})
X=$(bc <<< $X-$WIDTH)
Y=1

BATTERY_CHARGING_ICON="${ICON_SRC}/ac_01.xbm"
BATTERY_DISCHARGING_ICON="${ICON_SRC}/bat_full_02.xbm"
BATTERY_MISSING_ICON="${ICON_SRC}/ac_01.xbm"
CLOCK_ICON="${ICON_SRC}/clock.xbm"
CPU_ICON="${ICON_SRC}/cpu.xbm"
DBOX_ICON="${ICON_SRC}/dbox.xbm"
DOWN_ICON="${ICON_SRC}/net_down_03.xbm"
EMAIL_ICON="${ICON_SRC}/mail.xbm"
GPU_ICON="${ICON_SRC}/temp.xbm"
HDD_ICON="${ICON_SRC}/diskette.xbm"
MEM_ICON="${ICON_SRC}/mem.xbm"
UP_ICON="${ICON_SRC}/net_up_03.xbm"
VOLUME_ICON="${ICON_SRC}/spkr_01.xbm"
WIRELESS_ICON="${ICON_SRC}/wifi_01.xbm"

IFACE=lo # default
RXB=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
TXB=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)

CLOCK_FORMAT="%I:%M"

CRITICAL_PERCENTAGE=20
BAR_EXEC=gdbar # default on archlinux
BAR_STYLE="-w 33 -h 10 -s o -ss 1 -max 101 -sw 1 -nonl"
CRIT_BAR_STYLE="-w 33 -h 10 -s o -ss 1 -max 20 -sw 5 -nonl"


# -- Helpers {{{
icon() {
    echo "^fg($ICON_COLOR)^i($1)^fg()"
}

bar() {
    echo "$1" | $BAR_EXEC $BAR_STYLE -fg $2 -bg $BAR_BG_COLOR
}

crit_bar() {
    echo $1 | $BAR_EXEC $CRIT_BAR_STYLE -fg $2 -bg $BAR_BG_COLOR
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
    local percentage=$(acpi -b | cut -d "," -f 2 | tr -d " %")
    if [ -z "$percentage" ]; then
        echo "AC"
    elif [ $percentage -le $CRITICAL_PERCENTAGE ] ; then
        crit_bar "$percentage" $BAR_CRITICAL_COLOR
    else
        bar "$percentage" $BAR_FG_COLOR
    fi
}

battery() {
    local battery_status=$(acpi -b | cut -d ' ' -f 3 | tr -d ',')
    echo $(battery_icon) $(battery_percentage)
}
# }}}


# -- Wireless {{{
wireless_quality() {
    local quality_bar=$(cat /proc/net/wireless | grep $IFACE | cut -d ' ' -f 6 | tr -d '.')
    if [ -z "$quality_bar" ] ; then
        bar 100 $BAR_CRITICAL_COLOR
    else
        quality_bar=$(printf "%0.0f" $(bc <<< "scale=10;($quality_bar/70)*100"))
        if [ "$quality_bar" -le $CRITICAL_PERCENTAGE ] ; then
            crit_bar $quality_bar $BAR_CRITICAL_COLOR
        else
            bar $quality_bar $BAR_FG_COLOR
        fi
    fi
}
#}}}


# -- Volume  {{{
volume() {
    local volume=$(amixer get Master | egrep -o "[0-9]+%" | tr -d "%")
    if [ -z "$(amixer get Master | grep "\[on\]")" ]; then
        echo -n "$(bar $volume $BAR_OFF_COLOR)"
    else
        echo -n "$(bar $volume $BAR_FG_COLOR)"
    fi
}
# }}}


# -- Clock {{{
clock() {
    echo "^fg($WHITE)$(date +"$CLOCK_FORMAT")^fg()"
}
#}}}


# -- Nvidia {{{
nvidia() {
    lsmod | grep nvidia &>/dev/null
    [ "$?" == "1" ] && echo "GPU: OFF" && return
    echo -n "GPU: "
    # what we have to do for optimus 
    if which bumblebeed &>/dev/null; then
        echo $(nvidia-settings -query GPUCoreTemp -c :8 | grep gpu | perl -ne 'print $1 if /GPUCoreTemp.*?: (\d+)./;')
    else
        echo $(nvidia-settings -q gpucoretemp -t)
        #echo $(nvidia-settings -query GPUCoreTemp | perl -ne 'print $1 if /GPUCoreTemp.*?: (\d+)./;')
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
    local NEW_RX=$(bc <<< "($RXBN - $RXB) / 1024 / $REFRESH_RATE")
    local NEW_TX=$(bc <<< "($TXBN - $TXB) / 1024 / $REFRESH_RATE")
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


# -- DBOX {{{
DB_CACHE="Connecting..."
DB_COUNTER=0
dbox()
{
    if [[ $DB_COUNTER -lt 5 ]]; then
        echo -n "$(icon $DBOX_ICON) $DB_CACHE"
        DB_COUNTER=$((DB_COUNTER+1))
        return
    fi
    
    DB_COUNTER=0
    DB_CACHE="$(dropbox status | sed  's/.*(\(.*\)).*/\1/' | head -1)"
    echo -n "$(icon $DBOX_ICON) $DB_CACHE"
}
# }}}


# vim: foldmethod=marker : 
