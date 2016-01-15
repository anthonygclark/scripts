#!/bin/bash
# Forwards network traffic to an interface.
# Used for sharing internet connections and
# intranets with only 1 WAN connection.

# Must allow ip_forwarding
# sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

DHCP_OUT=enp3s0
WAN_IN=wlp0s29u1u1

sudo -v || exit 1

sudo iptables -A FORWARD -o ${DHCP_OUT} -i ${WAN_IN} -s 192.168.0.0/16 -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A POSTROUTING -t nat -j MASQUERADE
