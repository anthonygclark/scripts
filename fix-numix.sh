#!/bin/bash
#
# The Numix gtk3 theme is awesome, but I hate
# orange. This makes it grey
#

function fail()
{
    echo "[-] $1"
    exit 1
}

sudo -v || fail "sudo"

cd /usr/share/themes/Numix || fail "cd"

sudo find -type f -exec sed -i 's/d64937/747474/g' {} \; || fail "sed"

echo "[+] Done"
