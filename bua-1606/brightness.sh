#!/bin/bash
[ -z "$1" ] && {
    cat /sys/class/backlight/intel_backlight/brightness
    exit 1
}

sudo -v || exit 1

[ "$1" != "up" ] && [ "$1" != "down" ] && [ "$1" != "max" ] && exit 1

TOTAL=$(cat /sys/class/backlight/intel_backlight/max_brightness)
CURR=$(cat /sys/class/backlight/intel_backlight/brightness)
[ -z $TOTAL ] || [ -z $CURR ] && exit 1

AMT_STEPS=7
STEP=$(bc <<< $TOTAL/$AMT_STEPS)
ROUNDED_TOTAL=$(bc <<< $STEP*$AMT_STEPS)

# normalize, set to middle
[ $(bc <<< "$CURR%$STEP") -ne 0 ] && {
    echo $(bc <<< "$STEP*($AMT_STEPS/2)") | sudo tee /sys/class/backlight/intel_backlight/brightness
}

if [ "$1" = "up" ] ; then
    [ "$CURR" -lt "$ROUNDED_TOTAL" ] && {
    echo $(bc <<< "$CURR+$STEP") | sudo tee /sys/class/backlight/intel_backlight/brightness
}
elif [ "$1" = "down" ] ; then
    [ "$CURR" -gt "$STEP" ] && {
    echo $(bc <<< "$CURR-$STEP") | sudo tee /sys/class/backlight/intel_backlight/brightness
}
elif [ "$1" = "max" ] ; then
    echo $TOTAL | sudo tee /sys/class/backlight/intel_backlight/brightness
fi
