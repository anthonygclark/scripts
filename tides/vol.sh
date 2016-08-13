#!/bin/bash
#
# volume - dzen volume bar

#Customize this stuff
IF="Master"         # audio channel: Master|PCM
SECS="1"            # sleep $SECS
BG="#151515"        # background colour of window
FG="#eeeeee"        # foreground colour of text/icon
BAR_FG_ON="#808080"    # foreground colour of volume bar
BAR_FG_OFF="#3c3c3c" # foreground colour of volume bar whe muted
BAR_BG="#090909"    # background colour of volume bar
XPOS="1100"          # horizontal positioning
YPOS="650"          # vertical positioning
HEIGHT="30"         # window height
WIDTH="270"         # window width
BAR_WIDTH="200"     # width of volume bar
ICON=~/.icons/dzen/spkr_01.xbm
FONT="-*-tamsyn-medium-r-*-*-13-*-*-*-*-*-*-*"
ICON_VOL=~/.icons/dzen/spkr_01.xbm
ICON_VOL_MUTE=~/.icons/dzen/spkr_02.xbm
ICON=$ICON_VOL

#Probably do not customize
PIPE="/tmp/volshpip"

err() {
    echo "$1"
    exit 1
}

usage() {
    echo "usage: $0 [option] [argument]"
    echo
    echo "Options:"
    echo "     -i, --increase - increase volume by \`argument'"
    echo "     -d, --decrease - decrease volume by \`argument'"
    echo "     -t, --toggle   - toggle mute on and off"
    echo "     -h, --help     - display this"
    exit
}

function get_first_sink()
{
    pactl list sinks | head -1 | cut -d# -f2
}


function pulse_get_volume()
{
    local ret=($(pactl list sinks | grep Volume | cut -d/ -f2 | tr -d ' ' | grep -o '[0-9]*'))
    echo ${ret[0]}
}


ACTION=""
SINK=$(get_first_sink)

#Argument Parsing
case "$1" in
    '-i'|'--increase')
        (( $(pulse_get_volume) >= 95 )) && exit 0
        (pactl set-sink-mute ${SINK} false &&
        pactl set-sink-volume ${SINK} \+5\%) &
        wait
        ACTION='up'
        ;;

    '-d'|'--decrease')
        (( $(pulse_get_volume) <= 0 )) && exit 0
        (pactl set-sink-mute ${SINK} false &&
        pactl set-sink-volume ${SINK} \-5\%) &
        wait
        ACTION='down'
        ;;

    '-t'|'--toggle')
        pactl set-sink-mute ${SINK} toggle
        ACTION='mute'
        ;;

    *)
        err "Unrecognized option \`$1', see dvol --help"
        ;;
esac

AMIXOUT="$()"

# current - should be sink0's volume
VOL=$(pulse_get_volume)
# Is muted?
MUTED=$(pactl list sinks | grep Mute\: | cut -d: -f2 | tr -d ' ')

echo "muted: $MUTED" >> /tmp/f
echo "new vol: $VOL" >> /tmp/f

if [[ $MUTED == 'yes' ]];
then
    ICON=$ICON_VOL_MUTE
    BAR_FG=$BAR_FG_OFF
else
    ICON=$ICON_VOL
    BAR_FG=$BAR_FG_ON
    #ogg123 /usr/share/sounds/freedesktop/stereo/bell.oga
fi

## set alsa
#case $ACTION in
#    'up'|'down')
#        amixer set "$IF" "$(( $VOL + 27 ))" | tail -n 1
#        ;;
#    'mute')
#        amixer set "$IF" "toggle" | tail -n 1
#        ;;
#esac

#Using named pipe to determine whether previous call still exists
#Also prevents multiple volume bar instances
if [ ! -e "$PIPE" ]; then
    mkfifo "$PIPE"
    (dzen2 -tw "$WIDTH" -h "$HEIGHT" -x "$XPOS" -y "$YPOS" -fn "$FONT" -bg "$BG" -fg "$FG" < "$PIPE"
    rm -f "$PIPE") &
fi

#Feed the pipe!
(echo "$VOL" | gdbar -l "^i(${ICON}) $(printf "%03s" $VOL) " -fg "$BAR_FG" -bg "$BAR_BG" -w "$BAR_WIDTH" ; sleep "$SECS") > "$PIPE"
