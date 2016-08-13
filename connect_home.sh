#!/bin/bash
TOK="Dialup"
RES=$(wicd-cli --wireless -l | grep $TOK) 

[[ -z $RES ]] && {
    echo "Failed to find wifi network with '$TOK'"
    exit 1
}

wicd-cli --wireless -c -n $(echo $RES | cut -d' ' -f1) || {
    echo "Failed to connect to network containing '$TOK'"    
    exit 1
}
