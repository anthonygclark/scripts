#!/bin/bash
# Forwards network traffic to an interface.
# Used for sharing internet connections and
# intranets with only 1 WAN connection.

# Must allow ip_forwarding
# sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

DHCP_OUT=eth0
WAN_IN=eth1

if [ "$(id -u)" != "0" ]; then
cat << EOF
Run as root.
EOF
  exit 1
fi

iptables -A FORWARD -o ${DHCP_OUT} -i ${WAN_IN} -s 192.168.1.0/24 -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A POSTROUTING -t nat -j MASQUERADE
