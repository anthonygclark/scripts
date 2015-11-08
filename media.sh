#!/bin/bash
#
# Media key handling
#

STOP_sym="stop"
PLAY_sym="toggle"
NEXT_sym="next"
PREV_sym="prev"

function check()
{
    if pgrep "$1" &>> /dev/null; then
        echo "1"
    else
        echo "0"
    fi
}

# the order of these commands is important... 'mpc' should be last
# as it runs as a daemon for me. If any other support player is first,
# it'll use that.

PLAY_COMMANDS=(
"dbus-send --print-reply --dest=org.mpris.MediaPlayer2.vlc /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause"
"dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause"
"mpc toggle"
)

STOP_COMMANDS=(
"dbus-send --print-reply --dest=org.mpris.MediaPlayer2.vlc /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop"
"dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop"
"mpc stop"
)

NEXT_COMMANDS=(
"dbus-send --print-reply --dest=org.mpris.MediaPlayer2.vlc /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next"
"dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next"
"mpc next"
)

PREV_COMMANDS=(
"dbus-send --print-reply --dest=org.mpris.MediaPlayer2.vlc /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous"
"dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous"
"mpc prev"
)

PLAYERS=(
$(check vlc)
$(check spotify)
$(check mpd)
)

# Find first active player
ACTIVE_PLAYER=-1
counter=0
for p in ${PLAYERS[@]};
do
    if (( $p == 1 )); then 
        ACTIVE_PLAYER=$counter
        break;
    fi
    (( counter++ ))
done

(( $ACTIVE_PLAYER == -1 )) && exit 0

case "$1" in
    $STOP_sym) ${STOP_COMMANDS[$ACTIVE_PLAYER]} ;;
    $PLAY_sym) ${PLAY_COMMANDS[$ACTIVE_PLAYER]} ;;
    $NEXT_sym) ${NEXT_COMMANDS[$ACTIVE_PLAYER]} ;;
    $PREV_sym) ${PREV_COMMANDS[$ACTIVE_PLAYER]} ;;
    *) exit 1 ;;
esac
