#!/bin/bash
#------~------~
# Anthony Clark
#------~------~
# Gives you a bootable disk with your directory directly
# in the root of the disk. This lets you run DOS BIOS utils
# easily.

export TMPBASE=/tmp/BIOS.XXX BIOS=bios

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
  echo ">Cleaning..."
  rm -rf $tmp
}

# Check for binaries
check(){
  # Check for dos2unix
  command -v dos2unix >/dev/null 2>&1 || { 
    echo >&2 "I require \"dos2unix\" but it's not installed.  Aborting." 
    exit 5; 
  }
  # Check for unix2dos
  command -v unix2dos >/dev/null 2>&1 || { 
    echo >&2 "I require \"unxi2dos\" but it's not installed.  Aborting." 
    exit 5; 
  }
  # Check for unzip
  command -v unzip >/dev/null 2>&1 || { 
    echo >&2 "I require \"unzip\" but it's not installed.  Aborting." 
    exit 5; 
  }
  # Check for unzip
  command -v mkisofs >/dev/null 2>&1 || { 
    echo >&2 "I require \"mkisofs\" but it's not installed.  Aborting." 
    exit 5; 
  }
}

# Post Run function
post_func(){
  echo "Add the following to GRUB4DOS menu.lst for booting ISO"
  echo
cat << EOF 
  title FreeDos BIOS Update
  find --set-root /`basename $out`
  map /`basename $out` (0xff)
  map --hook
  root (0xff)
  chainloader (0xff)
  boot
EOF
  echo
}

# Main
main () {
  local out= inc= exe= auto=0 tmp=$(mktemp -d $TMPBASE)
  while getopts :o:d:a Opt; do
    case $Opt in
      o) out=$OPTARG;;
      d) inc=$OPTARG;target=`basename $inc`; exe=`ls $inc | grep -i .exe | head -1`;;
      a) auto=1;;
     \?) help; exit;;
    esac
  done

  ## Check args and fields
  check
  [ -z "$out" -o -z "$inc" ] && help && exit 2
  [ -z "$exe" ] && echo "ERROR: No EXE was found in specified dir $inc" && help && exit 1

  cd $tmp

  ## Download and unzip FreeDos OEM Kit
  echo ">Downloading FreeDOS OEM..." >&2
  wget -Nq http://localhost/FDOEMCD.builder.zip
  
  echo ">Unarchiving..." >&2
  unzip -q FDOEMCD.builder.zip
  
  ## Put included files in the right place
  if [ ! -z "$inc" -a -d "$inc" ]; then
    echo ">Copying include files..." >&2
    cp -r $inc FDOEMCD/CDROOT || return $?
    cd $tmp/FDOEMCD/CDROOT/
    
    # Adding the EXE to autorun 
    if [ $auto -eq 1 ]; then
      echo ">Modifying AUTORUN..." >&2
      dos2unix -n AUTORUN.BAT ar.bat > /dev/null 2>&1
      echo "CD $target" | tr '[:lower:]' '[:upper:]' >> ar.bat
      echo "$exe" | tr '[:lower:]' '[:upper:]' >> ar.bat
      unix2dos -n ar.bat AUTORUN.BAT > /dev/null 2>&1
    fi
  else
    echo "ERROR: Cannot parse relative path, add ~/ to your output directory."
    clean
    exit
  fi

  ## Build the iso
  mkisofs -o "$out" -publisher "FreeDOS - www.freedos.org" -V FDOS \
    -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -N -J -r \
    -c boot.catalog -input-charset utf-8 -hide boot.catalog -hide-joliet boot.catalog $tmp/FDOEMCD/CDROOT || return $?

  ## Remove temp
  clean

  ## Run post build function
  echo ">Success!"
  post_func
}

main $@
