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
b8160a
be1810
c6180b
cc1a11
db1c12
e21b0c
e91e14
e91e14
ec2a20
ec2a20
ee382f
ee382f
ef463d
f01d0d
f2291a
f33628
f44336
)

MED=(
f0544c
f1625b
f1544D
f5584d
ee534cf7786f
f7786ff26a63
f58c86
)

LIGHT=(
f7786f
f26a63
f58c86
)


cd /usr/share/themes/Numix || fail "cd"
#cd ~/.themes/Numix

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
