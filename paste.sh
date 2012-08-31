#!/bin/bash
PASTE_DIR=~/web/paste
SERVER=http://aclarkdev.dyndns.org/paste

usage(){
  echo "$(basename $0) <file.extention>"
  exit 1
}

[ $# -ne 1 ] && usage

export DIR_BASE=$PASTE_DIR/PASTE.XXXX

tmp=$(mktemp -d $DIR_BASE)
DEST=$tmp
FILE=$1

filetype(){
  local ext=${1##*.}
  echo $ext
}

fail(){
  echo "Failed."
  rm -r $DEST
  exit 1
}

FT=`filetype $FILE`
highlight --style=moria -S $FT -I --inline-css -i $FILE -T $(basename $FILE) > $DEST/index.html || fail

# Fix perms
chmod 777 $DEST -R
echo "$SERVER/$(basename $DEST)/index.html"
