#!/bin/bash
#------~------~
# Anthony Clark
#------~------~
# Gives you a bootable disk with your directory directly
# in the root of the disk. This lets you run DOS BIOS utils
# easily.

export TMPBASE=/tmp/BIOS.XXX BIOS=bios

help () {
cat <<EOF	
Usage $0:
  -o output ISO file
  -d directory containing EXE
  -a Autoruns EXE upon boot
EOF
}

clean(){
  echo ">Cleaning..."
  rm -rf $tmp
}

main () {
	local out= inc= exe= auto=0 tmp=$(mktemp -d $TMPBASE)
	while getopts :o:d:a Opt; do
		case $Opt in
			o) out=$OPTARG;;
			d) inc=$OPTARG;target=`basename $inc`;exe=`ls $inc| grep -i .exe | head -1`;;
			a) auto=1;;
     \?) help; exit;;
		esac
	done

	[ -z "$out" -o -z "$inc" ] && help && exit 1
  [ -z "$exe" ] && echo "ERROR: No EXE was found in specified dir $inc" && help && exit 1

	cd $tmp
	
  echo ">Downloading FreeDOS OEM..." >&2
  wget -Nq http://localhost/FDOEMCD.builder.zip
	
  echo ">Unarchiving..." >&2
  unzip -q FDOEMCD.builder.zip

	if [ ! -z "$inc" -a -d "$inc" ]; then
	  echo ">Copying include files..." >&2
    cp -r $inc FDOEMCD/CDROOT || return $?
    cd $tmp/FDOEMCD/CDROOT/
    
    if [ $auto -eq 1 ]; then
      echo ">Modifying AUTORUN..." >&2
      dos2unix -n AUTORUN.BAT ar.bat > /dev/null 2>&1
      echo "CD $target" | tr '[:lower:]' '[:upper:]' >> ar.bat
      echo "$exe" | tr '[:lower:]' '[:upper:]' >> ar.bat
      unix2dos -n ar.bat AUTORUN.BAT > /dev/null 2>&1
      #cat AUTORUN.BAT
    fi
  else
    echo "ERROR: Cannot parse relative path, add ~/ to your output directory."
    clean
    exit
  fi

	mkisofs -o "$out" -publisher "FreeDOS - www.freedos.org" -V FDOS \
		-b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -N -J -r \
		-c boot.catalog -input-charset utf-8 -hide boot.catalog -hide-joliet boot.catalog $tmp/FDOEMCD/CDROOT || return $?
	clean
  echo ">Success!"
}

main $@
