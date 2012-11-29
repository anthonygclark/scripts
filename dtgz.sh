#!/bin/bash
# Dialog progress for targz
# Taken from `man pv`
[ $# -lt 2 ] && echo "Supply input files/dir and output filename.tgz" && exit 1

out=$1
shift; files=$@

(tar cf - $files \ | pv -n -s $(du -sbc $files | grep 'total' | awk '{print $1}') \
| gzip -9 > $out) 2>&1 | dialog --gauge 'Progress' 7 70
