#!/bin/bash
#------~------~
# Anthony Clark
#------~------~
# 
# Originally taken from Sam B.
#
# Gives you a bootable disk with your directory directly
# in the root of the disk. This lets you run DOS BIOS utils
# or games easily.

FDOS=FDOEMCD.builder.zip

export TMPBASE=/tmp/DOS.XXX DOS=dos

# Simple help
help () {
cat <<EOF 
Usage $0:
  -o output ISO file
  -d directory containing EXE
  -a Autoruns EXE upon boot
EOF
}

# Check Args
if [ $# -lt 3 ] ; then
  help
  exit 1
fi

# Removes Temp
clean(){
  echo ">Cleaning"
  rm -rf $tmp
}

# Check for binaries
check(){
  for prog in dos2unix unix2dos unzip mkisofs; do 
    command -v $prog >/dev/null 2>&1 || { 
      echo >&2 "I require \"${prog}\" but it's not installed.  Aborting." 
      exit 5; 
    }
  done
}

# Post Run function
post_func(){
  echo
  echo "Add the following to GRUB4DOS menu.lst for booting ISO"
  echo
cat << EOF 
title FreeDos
find --set-root /`basename $out`
map /`basename $out` (0xff)
map --hook
root (0xff)
chainloader (0xff)
boot
EOF
  echo
}


# Quick selection menu 
menu () {
  PS3="Select EXE: "
  cd "$1"
  list=$(find . -maxdepth 1 -type f -iname *.exe -o -iname *.bat)
  
  select exe in $list; do
    if [ -n "$exe" ]; then
      echo $(basename "$exe")
      break
    fi
    clean
  done
}


# Main
main () {
  # Check for required deps
  check
  
  local out= inc= exe= auto=0 tmp=$(mktemp -d $TMPBASE)
  while getopts :o:d:a Opt; do
    case "$Opt" in
      o) out="$OPTARG";;
      d) inc="$OPTARG";target=$(basename "$inc");;
      a) auto=1;;
     \?) help; exit;;
    esac
  done

  ## Check args and fields
  [ -z "$out" -o -z "$inc" ] && help && exit 2

  cd $tmp

  ## Download and unzip FreeDos OEM Kit
  echo ">Downloading FreeDOS OEM"
  wget -Nq http://localhost/misc/$FDOS
  
  echo ">Unarchiving"
  unzip -q FDOEMCD.builder.zip
  
  ## Put included files in the right place
  if [ ! -z "$inc" -a -d "$inc" ]; then
    echo ">Copying include files"
    cp -r $inc FDOEMCD/CDROOT || return $?
    cd $tmp/FDOEMCD/CDROOT/
    
    # Adding the EXE to autorun 
    if [ $auto -eq 1 ]; then
      echo ">Modifying AUTORUN"
      exe=$(menu "$inc")
      [ -z "$exe" ] && echo "ERROR: No EXE/BAT file was found in specified dir "$inc"" && break
      dos2unix -n AUTORUN.BAT ar.bat > /dev/null 2>&1
      echo "CD $target" | tr '[:lower:]' '[:upper:]' >> ar.bat
      echo "$exe" | tr '[:lower:]' '[:upper:]' >> ar.bat
      unix2dos -n ar.bat AUTORUN.BAT > /dev/null 2>&1
      rm ar.bat
    fi

  else
    echo $inc $auth
    echo "ERROR: Cannot parse relative path, add ~/ to your output directory."
    clean
    exit
  fi

  ## Build the iso
  echo ">Building ISO"
  mkisofs -o "$out" -publisher "FreeDOS - www.freedos.org" -V FDOS \
    -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -N -J -r \
    -c boot.catalog -input-charset utf-8 -hide boot.catalog -hide-joliet boot.catalog $tmp/FDOEMCD/CDROOT 2> /dev/null || clean

  ## Remove temp
  clean

  ## Run post build function
  echo ">Success!"
  post_func
}

main $@
