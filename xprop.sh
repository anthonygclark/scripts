#!/bin/bash
# Anthony Clark
# Gets a dwm friendly xprop output 
xprop |awk '
    /^WM_CLASS/{sub(/.* =/, "instance:"); sub(/,/, "\nclass:"); print}
    /^WM_NAME/{sub(/.* =/, "title:"); print}'
  
