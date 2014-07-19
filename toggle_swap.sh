#!/bin/bash
source $(dirname $(readlink -m $0))/task_source

# since 'Filename' isnt a REAL heading (eventhough it is)
DEV=$(swapon --show --noheadings | awk '{print $1}')
if ! [[ $DEV =~ '/dev/' ]] ; then exit 1; fi

echo "Toggling '$DEV'"
sudo -v || exit 1
sudo swapoff $DEV & waitProgress "Off..."   || exit 1
sudo swapon $DEV & waitProgress "On..."     || exit 1
