#!/bin/bash
script_dir=$(dirname $(readlink -m $0))
cd $script_dir

python2 tv_mover.py > /tmp/tv.log
echo "EXIT: $?" 

bash ../refresh-plex.sh
