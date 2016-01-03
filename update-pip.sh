#!/bin/bash
sudo -v 
sudo pip2 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs sudo pip2 install -U
