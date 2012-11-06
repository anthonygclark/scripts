#!/bin/bash
# is dropbox-cli installed?

command -v dropbox >/dev/null 2>&1 || { 
  echo "ERR"
  exit 1 
}

res=$(dropbox status)

if [[ $res =~ "Idle" ]]; then
  echo "idle"
elif [[ $res =~ "Downloading" ]]; then
  echo "downloading"
elif [[ $res =~ "Uploading" ]]; then
  echo "uploading"
elif [[ $res =~ "isn't" ]]; then
  echo "OFF"
elif [[ $res =~ "Index" ]]; then
  echo "indexing"
elif [[ $res =~ "Connecting" ]]; then
  echo "OFF"
fi
exit 0
