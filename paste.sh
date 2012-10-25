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

_highlight() {
  FT=`filetype $FILE`
  highlight --style=moria -S $FT -I --inline-css -i $FILE -T $(basename $FILE) > $DEST/index.html 
}

_highlight_default(){
  echo "Defaulting to plain-text"
  highlight --style=moria -S txt -I --inline-css -i $FILE -T $(basename $FILE) > $DEST/index.html 
}

# Highlight according to filetype
_highlight || _highlight_default || fail

# Move source to Destination dir
cp $FILE $DEST || fail

# Insert download link
sed -e "7i\\<a href=\"$(basename $FILE)\" style=\"color:#202020; background-color:#a8a8a8; text-decoration:None; padding:5px\">Download</a>" < $DEST/index.html > /tmp/__index.html || fail

mv /tmp/__index.html $DEST/index.html || fail

# Fix perms
chmod 777 $DEST -R
echo "$SERVER/$(basename $DEST)/index.html"
