#!/bin/bash
#
# More later ... 
#
sudo -v

SYS_FILES=(
"/etc/lighttpd.conf"
"/var/git"
"/var/git/.*"
"/var/lib/plexmediaserver"
"/srv/http"
)


HOME_FILES=(
"/home/anthony"
"/home/anthony/*"
)


echo "[+] Backuping up system files ..."
echo "tar -czf /tmp/a.tgz ${SYS_FILES[@]}"    

echo "[+] Backuping up home files ..."
echo "tar -czf /tmp/b.tgz ${HOME_FILES[@]}"    
