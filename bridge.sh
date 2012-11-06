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



if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Variables
interface=wlan0
bridge=br0
tap=tap0
group=vboxusers

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
}


bridge(){
  # Add the bridge
  brctl addbr ${bridge}
  
  # Set promisc mode
  ifconfig ${interface} 0.0.0.0 promisc
  
  # Bind the bridge to the interface
  brctl addif ${bridge} ${interface}
  
  # Get an IP from the router
  dhcpcd br0

  # Allow r/w on the tunnel/bridge
  chmod 0666 /dev/net/tun
  
  # Give the bridge control to vbox and its users
  tunctl -t ${tap} -g ${group}
  
  # Toggle it on
  ifconfig ${tap} up
  
  # Bind the bridge to the tap
  brctl addif ${bridge} ${tap}
}


unbridge(){
  # toggle the bridge and tap off
  ifconfig ${bridge} down
  ifconfig ${tap} down
  # Remove the bridge
  brctl delbr ${bridge}
  # Bring ${interface} up then down
  ifconfig ${interface} down
  wicd-cli --wired -c
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
    h)
      usage
      exit 1
      ;;   
    \?)
      usage
      exit 1
      ;;
  esac
done
