#!/bin/bash
SRC="/home/anthony/Music/"

dests=(
"anthony@mini:~/Music/iTunes/iTunes Media/Music"
#"anthony@server:/var/Music"
)

function _err()
{
    echo 1>&2 "Error: $1"
    exit 1
}

function _transfer()
{
    rsync -rvh -P --ignore-existing --times "$SRC" "$1"
}

function _delete()
{
    rsync -av --exclude=keepall --delete "$SRC" "$1"
}

if [[ ! -z $1 ]] ; then
    _transfer "$1" || _err "rsync via argument"
    exit 0
fi

for i in "${dests[@]}"; do
    echo -en "Sync with '$i'? [y/n]: "
    read ans

    case "$ans" in
        y|Y) _transfer "$i" || _err "rsync via dests, '$i'" ;;
        *)  ;;
    esac

    ans=""
    echo -en "Delete extra files from'$i' [y/n]: "
    read ans
    case "$ans" in
        y|Y) _delete "$i" || _err "rsync delete dests, '$i'" ;;
        *)  ;;
    esac
done
