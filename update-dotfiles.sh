#!/bin/bash
# ------~------~
# Anthony Clark
# ------~------~
# copies all of my dotfiles to my dotfiles repo
# and assures I dont push backup/swap files and
# only the files in the array below.

REPO=~/code/dotfiles

FILES=(
"/home/anthony/.vimrc" 
"/home/anthony/.vim"
"/home/anthony/.Xdefaults"
"/home/anthony/.bashrc"
"/home/anthony/.gitconfig"
"/home/anthony/.screenrc"
"/home/anthony/.xinitrc"
)

for i in "${FILES[@]}" 
do
  cp -r "$i" "$REPO"
done
  
rm -f $REPO/.vim/swap/*.swp 
rm -f $REPO/.vim/swap/*.swo
rm -f $REPO/.vim/backup/*~  
rm -f $REPO/.vim/backup/.*~ 
