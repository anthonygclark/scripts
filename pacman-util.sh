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
    comm -13 <(sort <(pacman -Qqm)) <(sort <(pacman -Qq))
}

function localonly()
{
    pacman -Qqm
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
