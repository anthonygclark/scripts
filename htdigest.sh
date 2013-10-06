#!/bin/bash
# Simple htdigest surrogate 
#   anthony clark

usage() {
cat << EOF
usage: $(basename $0) <realm> <user>
This script emulates htdigest by apache.
EOF
    exit 1
}

[ -z "$1" ] || [ -z "$2" ] && {
    usage
}

echo -n "Enter Password: "
read -s password_one
echo
echo -n "Repeat Password: "
read -s password_two
echo

[ "$password_one" != "$password_two" ] && {
    echo "Password mismatch."
    exit 1
}

[ -z "$password_one" ] && {
    echo "Bad password."
    exit 1
}

_hash=$(echo -n "$2:$1:$password_one" | md5sum | cut -b -32)
echo "$2:$1:$_hash"
