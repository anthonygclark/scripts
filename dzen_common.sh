# Remember that functions that modify variables outside
# their scope cannot be called in a subshell. ie -
# you cannot do `echo myf` if myf modifies vars outside
# itself.
REFRESH_RATE=4

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

WIDTH=900
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
WIFI_BAR_STYLE="-w 33 -h 10 -s o -ss 1 -max 71 -sw 1 -nonl"
BAR_STYLE="-w 33 -h 10 -s o -ss 1 -max 101 -sw 1 -nonl"
CRIT_BAR_STYLE="-w 33 -h 10 -s o -ss 1 -max 20 -sw 5 -nonl"


# -- Helpers {{{
function print_seperator()
{
    echo -n " $SEP"
}

function icon()
{
    echo "^fg($ICON_COLOR)^i($1)^fg()"
}

function bar()
{
    echo "$1" | $BAR_EXEC $BAR_STYLE -fg $2 -bg $BAR_BG_COLOR
}

function crit_bar()
{
    echo "$1" | $BAR_EXEC $CRIT_BAR_STYLE -fg $2 -bg $BAR_BG_COLOR
}
#}}}


# -- Battery {{{
function battery()
{
    local ret=""
    local acpi_=$(acpi -b)
    local status_=$(cut -d ' ' -f 3 <<< $acpi_ | tr -d ',')
    local percent_=$(cut -d ',' -f 2 <<< $acpi_ | tr -d '%')

    case "$status_" in
        "Charging")     ret="$(icon $BATTERY_CHARGING_ICON)"    ;;
        "Discharging")  ret="$(icon $BATTERY_DISCHARGING_ICON)" ;;
        *)              ret="$(icon $BATTERY_MISSING_ICON)"     ;;
    esac

    if [[ -n $percent_ ]] ;
    then
        if (( percent_ <= $CRITICAL_PERCENTAGE )) ; then
            ret="$ret $(crit_bar $percent_ $BAR_CRITICAL_COLOR)"
        else
            ret="$ret $(bar $percent_ $BAR_FG_COLOR)"
        fi
    fi

    echo -n "(${percent_## }%) $ret"
}
# }}}


# -- Wireless {{{
function wireless()
{
    local ret="$(icon $WIRELESS_ICON)"

    if grep $IFACE /proc/net/wireless &>/dev/null ;
    then
        local quality_=$(grep $IFACE /proc/net/wireless | cut -d ' ' -f 5 | tr -d '.')

        if (( $quality_ <= $CRITICAL_PERCENTAGE ));
        then
            ret="$ret $(BAR_STYLE=$WIFI_BAR_STYLE crit_bar $quality_ $BAR_CRITICAL_COLOR)"
        else
            ret="$ret $(BAR_STYLE=$WIFI_BAR_STYLE bar $quality_ $BAR_FG_COLOR)"
        fi
    else
        ret="$(ICON_COLOR=$RED icon $WIRELESS_ICON) $(BAR_STYLE=$WIFI_BAR_STYLE bar 100 $BAR_OFF_COLOR)"
    fi

    echo -n "^ca(1, wicd-gtk -n &>>/dev/null)${ret}^ca()"
}
#}}}


# -- Volume  {{{
function volume()
{
    local channel="Master"
    local ret="$(icon $VOLUME_ICON)"
    local volume_="$(amixer get $channel | egrep -o "[0-9]+%" | head -1 | tr -d "%")"

    if [[ -z $(amixer get $channel | grep "\[on\]") ]];
    then
        echo -n "$ret $(bar $volume_ $BAR_OFF_COLOR)"
    else
        echo -n "$ret $(bar $volume_ $BAR_FG_COLOR)"
    fi
}
# }}}


# -- Clock {{{
function clock()
{
    echo "^fg($WHITE)$(date +"$CLOCK_FORMAT")^fg() "
}
#}}}


# -- Nvidia {{{
function nvidia()
{
    local ret="$(icon $GPU_ICON) GPU:"

    if grep "nvidia" <<< $(lsmod) &>/dev/null; then
        ret="$ret ON"
        #ret="$ret $(nvidia-settings -q gpucoretemp -t)"
    else
        ret="$ret OFF"
    fi

    echo -n "$ret"
}
#}}}


# -- Hard disks {{{
function hdd()
{
    local used=$(df | grep "$1" | awk '{print $5}' | cut -d% -f1)

    if (( $(bc <<< "$used >= 75") )); 
    then
        echo -n "$(ICON_COLOR=$YELLOW icon $HDD_ICON) $used%"
    else
        echo -n "$(icon $HDD_ICON) $used%"
    fi
}
# }}}


# -- Memory {{{
function mem()
{
    local used=$(free -t | head -2 | tail -1 | awk '{print 100-int(($7/$2)*100)}')
    #echo (( 100 - $used )) >> /tmp/f

    if (( $(bc <<< "$used >= 75") )); 
    then
        echo -n "$(ICON_COLOR=$YELLOW icon $MEM_ICON) $used%"
    else
        echo -n "$(icon $MEM_ICON) $used%"
    fi

}
#}}}


# -- Network {{{
function net()
{
    #TODO check iface
    RXBN=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
    TXBN=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)
    local NEW_RX=$(bc <<< "($RXBN - $RXB) / 1024 / $REFRESH_RATE")
    local NEW_TX=$(bc <<< "($TXBN - $TXB) / 1024 / $REFRESH_RATE")
    printf "(%s) %s %6dkB/s %s %6dkB/s" ${IFACE} $(icon $DOWN_ICON) ${NEW_RX} $(icon $UP_ICON) ${NEW_TX}
    RXB=$(($RXBN))
    TXB=$(($TXBN))
}
# }}}


# -- CPU {{{
PREV_TOTAL=0
PREV_IDLE=0

function cpu()
{
    local CPU=($(cat /proc/stat | grep '^cpu '))
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
    echo -n "$(icon $CPU_ICON) $DIFF_USAGE%"

    PREV_TOTAL=$(($TOTAL))
    PREV_IDLE=$(($IDLE))
}
#}}}


# -- DBOX {{{
DB_COLOR=$YELLOW
DB_CACHE="connecting..."
DB_COUNTER=0
DB_INTERVAL=2

function dbox()
{
    if [[ $DB_COUNTER -lt $DB_INTERVAL ]]; 
    then
        echo -n "$(ICON_COLOR=$DB_COLOR icon $DBOX_ICON) $DB_CACHE"
        DB_COUNTER=$((DB_COUNTER+1))
        return
    fi

    DB_COUNTER=0

    # fail if command doesnt exist
    if ! command dropbox-cli &> /dev/null;
    then
        DB_CACHE="N/A"
        DB_COLOR=$RED
    else
        local _res="$(dropbox-cli status | sed  's/.*(\(.*\)).*/\1/' | head -1)"
        local _lres=${_res,,}
        DB_CACHE=${_lres}

        if [[ $_lres =~ "isn't" ]]; then
            DB_CACHE="off"
            DB_COLOR=$RED
        elif [[ $_lres =~ "up to date" ]]; then
            DB_CACHE="on"
            DB_COLOR=$GREEN
        elif [[ $_lres =~ "download" ]]; then
            DB_COLOR=$YELLOW
        elif [[ $_lres =~ "remaining" ]]; then
            DB_COLOR=$YELLOW
        elif [[ $_lres =~ "connecting" ]]; then
            DB_COLOR=$YELLOW
        else
            DB_COLOR=$ICON_COLOR
        fi
    fi

    echo -n "$(ICON_COLOR=$DB_COLOR icon $DBOX_ICON) $DB_CACHE"
}
# }}}


# vim: foldmethod=marker :
