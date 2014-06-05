#!/bin/bash
# ------~------~
# Anthony Clark
# ------~------~
# copies all of my dotfiles to my dotfiles repo
# and assures I dont push backup/swap files and
# only the files in the array below.
shopt -s extglob
source task_source

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
}


function _weechat()
{
    sed -i 's/\.password = ".*"/\.password/g' .weechat/irc.conf
    rm -f ${REPO}/.weechat/weechat.log
    rm -rf ${REPO}/.weechat/logs
}

function _vim()
{
    rm -rf ${REPO}/.vim/bundle/*
    git submodule init
    git submodule update
}

function _clean()
{
    git clean -fdx &>/dev/null; true
}

cd $REPO

export logFile=$(mktemp)

_task "_copy"    "Copying Dotfiles"
_task "_weechat" "Sanitizing Weechat"
_task "_vim"     "Cleaning vundle"

if [[ $1 != "-k" ]]; then
    _task "_clean"   "Cleaning git"
fi

echo "[+] Done"

if [[ $(wc -c < ${logFile}) != 0 ]]; then
    echo
    echo "Log------"
    cat ${logFile}
fi

rm ${logFile}
