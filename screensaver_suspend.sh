#!/bin/bash
#------~------~
# Anthony Clark
#------~------~
# Disables screensaver when a supplied
# window title is running.



if [ $# -ne 1 ]
then
  echo "Supply a Window Title"
  exit
fi

sleep 3
xdg-screensaver suspend `xwininfo -name "$1" | grep id\:|cut -d' ' -f4`
