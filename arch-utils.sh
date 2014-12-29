#!/bin/bash

function usage()
{
    cat << EOF
Random archlinux utilities

usage: $(basename $0) [-p] [-l] [-a]
    -p    Print official package
    -l    Print local packages
    -a    Print all packages
EOF
}   


function officialonly()
{
    yaourt -Q | grep -v local | sed 's/^.*\///' | cut -d' ' -f1
}

function localonly()
{
    yaourt -Q | grep local | sed 's/^.*\///' | cut -d' ' -f1
}

function all()
{
    pacman -Qq
}

while getopts "plah" opt; do
    case $opt in
        p) officialonly ;;
        l) localonly    ;;
        a) all;;
        h) usage;;
        \?) usage ;;
    esac
done
