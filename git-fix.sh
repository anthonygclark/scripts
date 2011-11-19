#!/bin/sh
#
# Anthony Clark
# Small utility to replace all of the commiter's names
# with a new name. Credit for this is given to whoever
# discovered it. I found it on stackoverflow and added
# argument passing and better modularity.


# This will eventually be a function in a larger git utility
# script.

if [ $# -ne 3 ]
then
  echo "Usage: $0 <target email address> <new name> <new email>"
  echo "*note* Arguments can be quoted if they contain spaces."
  exit $# 
fi

# These have to be exported so they can be passed
# to the `git` command.
export arg1=$1
export arg2=$2
export arg3=$3

git filter-branch -f --env-filter '
an="$GIT_AUTHOR_NAME"
am="$GIT_AUTHOR_EMAIL"
cn="$GIT_COMMITTER_NAME"
cm="$GIT_COMMITTER_EMAIL"

target="$arg1"
name="$arg2"
email="$arg3"

if [ "$GIT_COMMITTER_EMAIL" = "$target" ]
then
  cn="$name"
  cm="$email"
fi

if [ "$GIT_AUTHOR_EMAIL" = "$target" ]
then
  an="$name"
  am="$email"
fi

export GIT_AUTHOR_NAME="$an"
export GIT_AUTHOR_EMAIL="$am"
export GIT_COMMITTER_NAME="$cn"
export GIT_COMMITTER_EMAIL="$cm"
' -- --all
