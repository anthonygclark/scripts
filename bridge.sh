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
group=vboxusers
dhcp=dhcpcd
runfile=/tmp/bridge


# Sentinel to assure only one of the
# two opts get ran. Probably a better
# way of doing this.
legal=true


usage(){
    [ -n "$1" ] && echo $1

cat << EOF
Usage: `basename $0` [OPTION]
-u  bridge up, "<iface> <bridge> <inherit-mac-bool> <run-dhcp>"
-d  bridge down, <use dhcp to rebind bridge interface (bool)>
-h  help
EOF

    exit 1
}


[ $# -lt 1 ] && usage


get_mac() {
    mac=$(ip addr show $1 | grep 'link/ether' | cut -d' ' -f6)
    [ -n "$mac" ] && printf "%s" "$mac"
}


# find next avail tap
get_tap() {
    curr_tap_count=$(ip addr | grep tap | wc -l)
    printf "tap%s" $curr_tap_count
}


check_args() {
    local msg="Error: Args to bridge are bad"
    
    if [[ -z $1 ]] || [[ -z $2 ]] ; then
        usage "$msg"
    fi

    [ $(ip addr | grep $1 | echo $?) -eq "0" ] || usage "$msg"
    [ $(ip addr | grep $2 | echo $?) -eq "0" ] || usage "Bridge $2 already exists"
}


bridge(){
    args=($1)
    iface=${args[0]}
    bridge=${args[1]}
    inherit=${args[2]}
    do_dhcp=${args[3]}
        
    check_args ${iface} ${bridge}
    
    local tap=$(get_tap)
    printf "%s %s %s\n" $tap ${iface} ${bridge} >> "${runfile}"
    
    # Set interface down
    ifconfig ${iface} down
    
    # Add the bridge
    brctl addbr ${bridge}   || unbridge
    [ "${inherit}" == "yes" ] && ifconfig ${bridge} hw ether $(get_mac ${iface})
    
    # Set promisc mode
    ip link set ${iface} up promisc on

    # Allow r/w on the tunnel/bridge
    chmod 0666 /dev/net/tun

    # Give the bridge control to vbox and its users
    tunctl -t ${tap} -g ${group}

    # Toggle it on
    ifconfig ${tap} up
    
    # Bind the bridge to the tap
    brctl addif ${bridge} ${tap}
    
    # Bind the bridge to the interface
    brctl addif ${bridge} ${iface}
    
    [ "${do_dhcp}"  == "yes" ] && `${dhcp} ${bridge}`
}


# Reads from the run_file and unbinds
# the created bridges and taps
unbridge(){

    contents=$(cat ${runfile}) || exit 0
    taps=$(echo "$contents" | awk '{print $1}' | uniq)
    ifaces=$(echo "$contents" | awk '{print $2}' | uniq)
    bridges=$(echo "$contents" | awk '{print $3}' | uniq)

    for tap in $taps; do
        tunctl -d ${tap}
    done

    for bridge in $bridges; do
        ifconfig ${bridge} down
        brctl delbr ${bridge}
    done

    for iface in $ifaces; do
        ip link set ${iface} up promisc off
        ifconfig ${iface} down

        [ "$1" == "yes" ] && $(${dhcp} ${iface})
    done


    rm ${runfile}
    
    exit 0
}


# Get args
while getopts "u:d:h" opt; do
    case $opt in
        u)
            if [ $legal == false ] ; then
                break
            fi

            echo "Bridging..." >&2
            bridge "$OPTARG"

            legal=false;
            ;;
        d)
            if [ $legal == false ] ; then
                break
            fi

            echo "Unbridging..." >&2
            unbridge "$OPTARG"

            legal=false;
            ;;
        h|*)
            usage
            ;;
    esac
done
