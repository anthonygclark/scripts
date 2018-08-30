#!/bin/bash

[[ -z $1 ]] && {
    echo "$0 <submodule path>"
    exit 1
}

[[ ! -d .git ]] && {
    echo "Not in a git repo!"
    exit 1
}

git submodule deinit -f -- "$1" && rm -rf ".git/modules/$1" && git rm -f "$1"

