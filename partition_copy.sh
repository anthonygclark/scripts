#!/bin/sh
# Partition copy.
# Written by Sam B.
#
[ $# -lt 1 ] && echo 'I need a disc.' >&2 && exit 1
export disc=$1 table=$(mktemp /tmp/disc.XXXX)
shift;

echo 'Analyzing disc:' $disc

sfdisk -l $disc > $table
totalblocks=$(grep '^/' $table | tr -s '*' ' ' | awk '{ s += $5 } END { print s }')
endcyl=$(grep '^/' $table | tr -s '*' ' ' | tr -s '-' ' ' | awk '{ if($3 > s) s = $3 } END { print s }')
blocksize=$(grep -oE 'blocks of ([0-9]+) bytes' $table | cut -d ' ' -f 3)
cylindersize=$(grep -oE 'cylinders of ([0-9]+) bytes' $table | cut -d ' ' -f 3)
blockcount=$(echo "${endcyl} * ${cylindersize} / ${blocksize}" | bc)

dd if=$disc bs=$blocksize count=$blockcount $@

rm $table
