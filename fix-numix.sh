#!/bin/bash

function fail()
{
    echo "[-] $1"
    exit 1
}

sudo -v || fail "sudo"

cd /usr/share/themes/Numix || fail "cd"

sudo find -type f -exec sed -i 's/d64937/747474/g' {} \; || fail "sed"

echo "[+] Done"
