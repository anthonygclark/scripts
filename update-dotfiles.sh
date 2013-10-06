#!/bin/bash
# ------~------~
# Anthony Clark
# ------~------~
# copies all of my dotfiles to my dotfiles repo
# and assures I dont push backup/swap files and
# only the files in the array below.

REPO=$HOME/code/dotfiles

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
)

for i in "${FILES[@]}" 
do
  cp -r "$i" "$REPO"
done
  
rm -f $REPO/.vim/swap/*.swp 
rm -f $REPO/.vim/swap/*.swo
rm -f $REPO/.vim/backup/*~  
rm -f $REPO/.vim/backup/.*~ 
