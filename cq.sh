#!/bin/bash

[[ $# -ne 1 ]] && {
    echo "Usage: $(basename "$0") <output db>"
    exit 1
}

find . -iname "*.c"    > ./cscope.files
find . -iname "*.cpp" >> ./cscope.files
find . -iname "*.C"   >> ./cscope.files
find . -iname "*.cxx" >> ./cscope.files
find . -iname "*.cc " >> ./cscope.files
find . -iname "*.h"   >> ./cscope.files
find . -iname "*.hpp" >> ./cscope.files
find . -iname "*.hxx" >> ./cscope.files
find . -iname "*.hh"  >> ./cscope.files

# exit early if no files were found
[[ -s ./cscope.files ]] || exit 2

cscope -cbk
ctags --fields=+i -n -R -L ./cscope.files -o ./tags
cqmakedb -s "$1" -c ./cscope.out -t ./tags -p

rm -f ./cscope.files
rm -f ./cscope.out
rm -f ./tags

echo "Done."
