#!/bin/bash
REFRESH_RATE=1

function get_iface()
{
    local _list=$(ip -o l | perl -lane'$F[1]=~s/://g;print $F[1]')
    PS3="Select interface:"
    select iface in $_list; do
        if [[ -n $iface ]]; then
            echo $iface
            break
        fi
    done
}


IFACE=${1:-$(get_iface)}

RXB=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
TXB=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)

function net() {
  RXBN=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
  TXBN=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)
  local NEW_RX=$(echo "($RXBN - $RXB) / 1024 / $REFRESH_RATE" | bc)
  local NEW_TX=$(echo "($TXBN - $TXB) / 1024 / $REFRESH_RATE" | bc)
  echo -ne "                                  \r"
  echo -ne "\r↓ ${NEW_RX}kB/s  ↑ ${NEW_TX}kB/s   "
  RXB=$(($RXBN))
  TXB=$(($TXBN))
}

echo

while :; do
  net;
  sleep $REFRESH_RATE
done


