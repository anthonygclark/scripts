#!/bin/bash
# Anthony Clark
# copies all of my dotfiles to my dotfiles repo
# and assures I dont push backup/swap files and
# only the files in the array below.

REPO=~/code/dotfiles

FILES=(
"/home/anthony/.vimrc" 
"/home/anthony/.vim"
"/home/anthony/.Xdefaults"
"/home/anthony/.bashrc"
)

#this deletes vim's tmp files
cd ~/.vim/backup/
ls -a | xargs rm > /dev/null 2>&1
cd $OLD_PWD

for i in "${FILES[@]}" 
do
  cp -r "$i" "$REPO"
done
