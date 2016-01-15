#!/bin/bash
# Forwards network traffic to an interface.
# Used for sharing internet connections and
# intranets with only 1 WAN connection.

IN=$1
OUT=$2
SUBNET=$3

function usage()
{
    cat << EOF
Usage: $(basename $0) <src if> <dst if> <subnet>
    example, $(basename $0) eth0 eth1 192.168.0.0/16
EOF
}

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] ; then
    usage
    exit 1
fi

sudo -v || exit 1

sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

sudo iptables -A FORWARD -o ${OUT} -i ${IN} -s ${SUBNET} -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A POSTROUTING -t nat -j MASQUERADE
