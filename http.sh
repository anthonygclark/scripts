#!/bin/bash
# ---~---~---~-
# Anthony Clark
# ---~---~---~-
# Contributors: Sam B.
#
# uses nc (netcat) to host a single file over 
# HTTP on port 8099 (or as specified)
#
# Provides an HTTP-compatible response on the 
# specified port, serving the specified file only.
#
# There are multiple ways to download this file from
# a client:
#
#    curl http://host:8099 > myFile
#    
#                 or
#    
#    Add `content-disposition=on` to ~/.wgetrc, then
#    wget http://host:8099
#
#                 or
#
#    wget http://host:8099 -O myFile
#
#                 or 
#
#    Visit the page in a web browser
#######################################################
port=${2:-8099}
bin="nc"

usage() {
  echo "Usage: $0 <file> [<port>]"
}

Request () { # read the incoming request, alter the response conditions
  sed -r '/^GET/{ s%^GET (.*) HTTP(.*)% filename="\1"%; p; }; d;'
}

Server(){
  MimeType=$(file --mime-type -b "$1")

  echo "HTTP/1.1 200 OK"
  echo "Content-Length: $(stat -c %s "$1")"
  echo "Connection: Close"
  echo "Content-Type: $MimeType"
  [ -z $(echo "$MimeType" | egrep -o "^(text|image)") ] && printf "Content-Disposition: attachment; filename=\"%s\"\n" "$filename"

  echo "" # blank line to delimit response body
  cat "$1"
}

[ $# -eq 0 ] && usage && exit 1

# Print intro messages
$bin -h 2>&1 | grep "OpenBSD netcat" && NC_ARGS="-l -p $port"
echo "Port $port"

filename="$(basename $1)"
while Server "$1" | $bin $NC_ARGS | eval $(Request); do
  echo "## Sent $1 $(date)"
done
