#!/bin/bash

lsmod | grep nv &>/dev/null
[ "$?" == "1" ] && echo "GPU: OFF" && exit 0
echo "GPU: ON" && exit 1
