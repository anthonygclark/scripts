#!/bin/bash

status=$(amixer sget Master | tail -1 | cut -d' ' -f 8)

if [[ $status =~ "[off]" ]]; then
    for ch in Headphone Front Master; do
        amixer -q sset $ch toggle
    done

else
    amixer -q sset Master toggle
fi
