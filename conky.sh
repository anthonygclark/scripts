#!/bin/bash
# Launches Conky and dzen2 with
# psuedo profiles for the machine

killall conky

asus(){
  sleep 4s && conky | dzen2 -x '1470' -y '1' -e '' -fg '#696969' -bg '#121212' -w '450' -h '13' -ta r -fn '-*-cure-medium-r-*-*-12-*-*-*-*-*-*-*' -p &
}

viking(){
  sleep 4s && conky | dzen2 -x '570' -y '1' -e '' -fg '#696969' -bg '#121212' -w '450' -h '13' -ta r -fn '-*-cure-medium-r-*-*-12-*-*-*-*-*-*-*' -p &
}

tides(){
  sleep 4s && conky | dzen2 -x '920' -y '1' -e '' -fg '#696969' -bg '#121212' -w '450' -h '13' -ta r -fn '-*-cure-medium-r-*-*-12-*-*-*-*-*-*-*' -p &
}


if [ `hostname` == "Asus" ]
  then
  asus
fi

if [ `hostname` == "viking" ]
  then
  viking
fi

if [ `hostname` == "tides" ]
  then
  tides
fi
