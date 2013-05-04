#!/bin/bash
#------~------~
# Anthony Clark
#------~------~
#
# Toggles on and off a bridged 
# adapter on eth0. Primarily used
# for virtualbox and allowing a VM
# to get a real IP from a router/dhcp
# server. Shouldn't be specific to Arch
# linux, but not tested.
#
# TODO swtich from ifconfig to ip
#



if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Variables
interface=enp3s0
bridge=br0
tap=tap0
group=vboxusers
dhcp=dhcpcd

# The mac address to set on the bridge
# Optional
INHERITED_MAC=bc:ae:c5:d7:2c:72


# Sentinel to assure only one of the
# two opts get ran. Probably a better
# way of doing this.
legal=true


usage(){
cat << EOF
Usage: `basename $0` [OPTION]
-u  bridge up
-d  bridge down
-h  help
EOF
    exit 1
}


[ $# -lt 1 ] && usage


bridge(){
    # Set interface down
    ifconfig ${interface} down
    
    # Add the bridge
    brctl addbr ${bridge}
    brctl setfd br0 0 
    brctl stp br0 on
    [ -n "$INHERITED_MAC" ] && ifconfig ${bridge} hw ether ${INHERITED_MAC}
    
    # Set promisc mode
    ip link set ${interface} up promisc on

    # Allow r/w on the tunnel/bridge
    chmod 0666 /dev/net/tun

    # Give the bridge control to vbox and its users
    tunctl -t ${tap} -g ${group}

    # Toggle it on
    ifconfig ${tap} up
    
    # Bind the bridge to the tap
    brctl addif ${bridge} ${tap}
    brctl show
    
    # Bind the bridge to the interface
    brctl addif ${bridge} ${interface}
    brctl show
    
    `${dhcp} ${bridge}`
}


unbridge(){
    ip link set ${interface} up promisc off
    ifconfig ${bridge} down
    ifconfig ${tap} down

    # Remove the bridge
    brctl delbr ${bridge}
    # Remove tap
    tunctl -d ${tap}

    # Bring ${interface} up then down
    ifconfig ${interface} down
    `${dhcp} ${interface}`
}


# Get args
while getopts "udh" opt; do
    case $opt in
        u)
            if [ $legal == false ] ; then
                break
            fi

            echo "Bridging..." >&2
            bridge

            legal=false;
            ;;
        d)
            if [ $legal == false ] ; then
                break
            fi

            echo "Unbridging..." >&2
            unbridge

            legal=false;
            ;;
        h|*)
            usage
            ;;
    esac
done
