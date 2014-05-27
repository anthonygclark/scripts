#!/bin/bash
# ---~---~---~-
# Anthony Clark
# ---~---~---~-
# Contributors: Sam B.
#
# uses nc (netcat) to host a single file over 
# HTTP on port 8099 (or as specified)

if (( $# == 0 )) ; then 
    echo "Usage: $(basename $0) <file> [port]"
    exit 1
fi

PORT=${2:-8099}


function Request ()
{ 
    # read the incoming request, alter the response conditions
    sed -r '/^GET/{ s%^GET (.*) HTTP(.*)% filename="\1"%; p; }; d;'
}


function Server()
{
    [[ -z $1 ]] && echo -en ""

    local mimetype=$(file --mime-type -b "$1")
    local filename=$(basename "$1")

    echo "HTTP/1.1 200 OK"
    echo "Content-Length: $(stat -c %s "$1")"
    echo "Connection: Close"
    echo "Content-Type: $mimetype"
    [[ -z $(echo "$mimetype" | egrep -o "^(text|image)") ]] && printf "Content-Disposition: attachment; filename=\"%s\"\n" "$filename"

    echo "" # blank line to delimit response body
    cat "$1"
}


# Print intro messages
nc -h 2>&1 | grep "OpenBSD netcat"
echo "Port $PORT"


# 'chroot' into dir
cd $(dirname $(readlink -m $1))


while Server "$1" | nc -l -p $PORT | eval $(Request); do
    echo "## Sent $1 $(date)"
done
