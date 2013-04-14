#!/bin/bash
# Dumps transmission's vars
cat << EOF > $HOME/transmission_dump
VER:  $TR_APP_VERSION
TIME: $TR_TIME_LOCALTIME
DIR:  $TR_TORRENT_DIR
HASH: $TR_TORRENT_HASH
ID:   $TR_TORRENT_ID
NAME: $TR_TORRENT_NAME
EOF
