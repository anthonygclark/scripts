#!/bin/bash
# Anthony Clark
#
#	VLC shortcut to start up http stream of my media at port 1234
#	as well as forwarding the playlist to http port 8080.

# Edit /usr/share/vlc/http/.hosts to have the Localhost uncommented
# and the line containing `192.168.0.0/16`

#Checks arguments
if [ $# -lt 1 ]; then
cat << EOF
Usage: `basename $0` [MEDIA FOLDER] [PORT]
*Port will default to 1234 if not specified
EOF
	exit 0
fi

# Sets the port, defaults to 1234
PORT=${2:-1234}

#Gets the Local IP of the machine
IP=$(ifconfig -a | awk '/(cast)/ { print $2 }' | cut -d':' -f2 | head -1)

#Runs VLC
vlc -vvv -I http "$1" --sout '#standard{access=http,mux=ts,dst='$IP':'$PORT'}' #> /dev/null 2>&1

