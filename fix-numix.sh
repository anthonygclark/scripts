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

#sudo -v || fail "sudo"

DARK=(
d64937
f44336
ee382f
c6180b
f2291a
f33628
b8160a
f01d0d
e91e14
db1c12
cc1a11
ec2a20
be1810
ee382f
ef463d
ec2a20
e91e14
e21b0c
)

MED=(
f0544c
f1625b
f1544D
f5584d
)

LIGHT=(
f7786f
f26a63
f58c86
)

#cd /usr/share/themes/Numix || fail "cd"
cd ~/.themes/Numix

for i in ${DARK[@]}; 
do 
    echo "Dark  Color : $i"
    find -type f -exec sed -i "s/$i/747474/g" {} \; || fail "sed"
done

for i in ${MED[@]}; 
do 
    echo "Med.  Color : $i"
    find -type f -exec sed -i "s/$i/989898/g" {} \; || fail "sed"
done

for i in ${LIGHT[@]}; 
do 
    echo "Light Color : $i"
    find -type f -exec sed -i "s/$i/aaaaaa/g" {} \; || fail "sed"
done

echo "[+] Done"
