#!/bin/bash
script_dir=$(dirname $(readlink -m $0))
cd $script_dir

./tvmover.py > /tmp/tv.log

[ -e "refresh-plex.sh" ] && refresh-plex.sh
