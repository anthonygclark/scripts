#!/bin/bash
# ------~------~
# Anthony Clark
# ------~------~
# copies all of my dotfiles to my dotfiles repo
# and assures I dont push backup/swap files and
# only the files in the array below.
shopt -s extglob
source task_source

export logFile=$(mktemp)
REPO="$HOME/code/dotfiles"

FILES=(
"$HOME/.vimrc" 
"$HOME/.vim"
"$HOME/.Xresources"
"$HOME/.bashrc"
"$HOME/.bash_profile"
"$HOME/.gitconfig"
"$HOME/.screenrc"
"$HOME/.xinitrc"
"$HOME/.pyrc"
"$HOME/.tmux.conf"
"$HOME/.weechat"
"$HOME/.config/dunst/dunstrc"
)

function _copy()
{
    local base
    local dest
    cd $REPO
    
    for i in "${FILES[@]}"; do
        base=$(dirname $i)
        base=${base#$HOME}
        
        # we have a subdirectory
        if [[ ! -e $base ]]; then
            dest="${REPO}/${base#/}"
            mkdir -p  ${dest}
        else
            dest="${REPO}"
        fi
        
        cp -r "$i" "${dest}"
    done
} >>$logFile


function _weechat()
{
    sed -i 's/\.password = ".*"/\.password/g' .weechat/irc.conf
    sed -i 's/\.sasl_password = ".*"/\.sasl_password/g' .weechat/irc.conf
    rm -f ${REPO}/.weechat/weechat.log
    rm -rf ${REPO}/.weechat/logs
    rm -f ${REPO}/.weechat/script/*.gz
    rm -f ${REPO}/.weechat/weechat_fifo*
} >>$logFile


function _vim()
{
    rm -rf ${REPO}/.vim/bundle/*
    git submodule init
    git submodule update
    git submodule foreach git pull origin master
    true
} >>$logFile


function _clean()
{
    git clean -fdx &>/dev/null; true
} >>$logFile


function _remove_nested_git()
{
    find . -type d -path '*/*/.git' -exec rm -r {} \;
} >>$logFile


cd $REPO
_remove_nested_git & waitProgress "Removing nested git dirs"

_copy    & waitProgress "Copying Dotfiles"
_weechat & waitProgress "Sanitizing Weechat"
_vim     & waitProgress "Cleaning vundle, adding submodule"

_remove_nested_git & waitProgress "Removing nested git dirs"

if [[ $1 != "-k" ]]; then
    _clean & waitProgress "Cleaning git"
fi

echo "[+] Done"

if [[ $(wc -c < ${logFile}) != 0 ]]; then
    echo
    echo "Log------"
    cat ${logFile}
fi

rm ${logFile}
