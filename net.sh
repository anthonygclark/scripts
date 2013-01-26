#!/bin/bash
REFRESH_RATE=1
IFACE=eth0
RXB=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
TXB=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)

net() {
  RXBN=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes)
  TXBN=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes)
  local NEW_RX=$(echo "($RXBN - $RXB) / 1024 / $REFRESH_RATE" | bc)
  local NEW_TX=$(echo "($TXBN - $TXB) / 1024 / $REFRESH_RATE" | bc)
  echo -ne "  ↓ ${NEW_RX}kB/s  ↑ ${NEW_TX}kB/s\r"
  RXB=$(($RXBN))
  TXB=$(($TXBN))
}

while :; do
  net;
  sleep $REFRESH_RATE
done


