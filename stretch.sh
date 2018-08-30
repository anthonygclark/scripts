#!/bin/bash
sudo systemd-nspawn -b -D .chroots/stretch/ --bind-ro /tmp/.X11-unix/ --bind-ro /home/aclark/.Xauthority --bind /home/aclark/share --bind /usr/local/MATLAB/
