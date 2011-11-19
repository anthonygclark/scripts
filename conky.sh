#!/bin/bash

# Launches Conky and dzen2 with
# psuedo profiles for the machine


asus(){
  sleep 4s && conky | dzen2 -x '1400' -y '3' -e '' -fg '#696969' -bg '#121212' -w '450' -h '13' -ta r -fn '-*-tamsyn-medium-*-*-*-12-*-*-*-*-*-*-*' -p &
  sleep 4s && conky | dzen2 -xs 2 -x '760' -y '3' -e '' -fg '#696969' -bg '#121212' -w '450' -h '13' -ta r -fn '-*-tamsyn-medium-*-*-*-12-*-*-*-*-*-*-*' -p &
}

viking(){
  echo "I need configured"
}


if [ `hostname` == "Asus" ]
  then
  asus
fi

if [ `hostname` == "viking" ]
  then
  viking
fi
