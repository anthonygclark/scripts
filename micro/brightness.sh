#!/bin/bash
SRC="/sys/class/backlight/intel_backlight"

ACPI_MODE=${ACPI_MODE:-0}


[[ -z $1 ]] && { 
    if (( ACPI_MODE != 1)) && which xbacklight > /dev/null; then
        printf "%.f" $(xbacklight -get)
    else
        cat $SRC/brightness
    fi
    exit 1
}

function _xbacklight()
{
     case $1 in
        up|+|UP)
            xbacklight -inc 25 -steps 1
            ;;
        down|-|DOWN)
            xbacklight -dec 25 -steps 1
            ;;
        max|=|MAX)
            xbacklight -set 100 -steps 1
            ;;
        min|*|MIN)
            xbacklight -set 25 -steps 1
            ;;
        *)
            ;;
    esac
   
}

function _brightness()
{
    sudo -v || return 1
    local TOTAL=$(cat $SRC/max_brightness)
    local CURR=$(cat $SRC/brightness)
    [[ -z $TOTAL ]] || [[ -z $CURR ]] && return 1

    local AMT_STEPS=7
    local STEP=$(bc <<< $TOTAL/$AMT_STEPS)
    local ROUNDED_TOTAL=$(bc <<< $STEP*$AMT_STEPS)
    
    # normalize, set to middle
    #if [ $(bc <<< "$CURR%$STEP") -ne 0 ]; then
    #    echo $(bc <<< "$STEP*($AMT_STEPS/2)") | sudo tee $SRC/brightness
    #fi
    
    case $1 in
        up|+|UP)
            [ "$CURR" -lt "$ROUNDED_TOTAL" ] && {
                echo $(bc <<< "$CURR+$STEP") | sudo tee $SRC/brightness
            }
            ;;
        down|-|DOWN)
            [ "$CURR" -gt "$STEP" ] && {
                echo $(bc <<< "$CURR-$STEP") | sudo tee $SRC/brightness
            }
            ;;
        max|=|MAX)
            echo $TOTAL | sudo tee $SRC/brightness
            ;;
        min|*|MIN)
            echo $STEP | sudo tee $SRC/brightness
            ;;
        *)
            ;;
    esac
}

ACPI_MODE=${ACPI_MODE:-0}

if (( ACPI_MODE != 1)) && which xbacklight > /dev/null; then
    _xbacklight $@
else   
    _brightness $@
fi
exit $?
