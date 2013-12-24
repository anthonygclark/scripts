#!/bin/bash
# ------~------~
# Anthony Clark
# ------~------~
# copies all of my dotfiles to my dotfiles repo
# and assures I dont push backup/swap files and
# only the files in the array below.
shopt -s extglob

REPO="$HOME/code/dotfiles"

FILES=(
"$HOME/.vimrc" 
"$HOME/.vim"
"$HOME/.Xdefaults"
"$HOME/.bashrc"
"$HOME/.bash_profile"
"$HOME/.gitconfig"
"$HOME/.screenrc"
"$HOME/.xinitrc"
"$HOME/.pyrc"
"$HOME/.weechat"
)

echo "[+] Copying"
for i in "${FILES[@]}" 
do
  cp -r "$i" "$REPO" || exit 1
done
 
echo "[+] Sanitizing"
sed -ni '/\[server_default\]/,$!p' $REPO/.weechat/irc.conf
rm -f $REPO/.weechat/weechat.log
rm -rf $REPO/.weechat/logs

cd $REPO
echo "[+] Cleaning"
git clean -fdx &>/dev/null 

echo "[+] Done"
