#!/bin/bash
# To use X11 in chroot:
#   (chroot)# export DISPLAY=:1
#   (host)$ Xnest -ac -geometry 800x600 :1
#   (chroot)# app & disown
#

CHROOT_PATH="/home/aclark/.chroots/stretch"

if [[ ! -e $CHROOT_PATH ]]; then
    echo "'$CHROOT_PATH' doesnt exist! Exiting."
    exit 1
fi

if (( UID !=0 )) ; then
    echo "Must be root."
    exit 1
fi

#echo "Mounting sysfs"
#mount sysfs "$CHROOT_PATH"/sys -t sysfs
echo "Mounting /proc"
mount --bind /proc "$CHROOT_PATH"/proc
echo "Mounting /dev"
mount --bind /dev "$CHROOT_PATH"/dev
echo "Mounting /dev/pts"
mount --bind /dev/pts "$CHROOT_PATH"/dev/pts
#echo "Sharing mount info"
#cp /proc/mounts "$CHROOT_PATH"/etc/mtab

TERM=xterm chroot $CHROOT_PATH /bin/bash -l

echo "Unmounting ... "
umount "$CHROOT_PATH"/proc
umount "$CHROOT_PATH"/dev/pts
umount "$CHROOT_PATH"/dev
