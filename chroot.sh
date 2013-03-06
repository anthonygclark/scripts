#!/bin/bash
#
# To use X11 in chroot:
#   - install xnest on the host
#   - run xnest
#     $ Xnest -ac -geometry 800x600 :1
#   
#   - in .bashrc or somewhere in the chroot
#       export DISPLAY=:1
#

CHROOT_PATH=/home/anthony/code/debian

[ $(whoami) != "root" ] && {
    echo "Must be root."
    exit 1
}

echo "Mounting sysfs"
mount sysfs "$CHROOT_PATH"/sys -t sysfs 
echo "Mounting proc"
mount proc  "$CHROOT_PATH"/proc -t proc 
echo "Mounting pts"
mount pts "$CHROOT_PATH"/dev/pts -t devpts
echo "Mounting dev"
mount -o bind /dev "$CHROOT_PATH"/dev
echo "Sharing mount info"
cp /proc/mounts "$CHROOT_PATH"/etc/mtab 

TERM=xterm chroot $CHROOT_PATH

echo "Unmounting ... "
umount "$CHROOT_PATH"/proc
umount "$CHROOT_PATH"/sys
umount "$CHROOT_PATH"/dev
umount "$CHROOT_PATH"/dev/pts
