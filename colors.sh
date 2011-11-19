#!/bin/bash
#------~------~
# Anthony Clark
#------~------~
# Color script. Functionality taken from others.
# Put in to functions by me.
#

usage(){
cat << EOF
Usage $0:
  -b Show color block
  -z Show color zigzags
  -h Show color hashes
EOF
}

block(){
  FGNAMES=(' black ' '  red  ' ' green ' ' yellow' '  blue ' 'magenta' '  cyan ' ' white ')
  BGNAMES=('DFT' 'BLK' 'RED' 'GRN' 'YEL' 'BLU' 'MAG' 'CYN' 'WHT')
  
  echo "     ┌──────────────────────────────────────────────────────────────────────────┐"
  for b in {0..8}; do
    ((b>0)) && bg=$((b+39))
  
    echo -en "\033[0m ${BGNAMES[b]} │ "
    
    for f in {0..7}; do
      echo -en "\033[${bg}m\033[$((f+30))m ${FGNAMES[f]} "
    done
    
    echo -en "\033[0m │"
    echo -en "\033[0m\n\033[0m     │ "
    
    for f in {0..7}; do
      echo -en "\033[${bg}m\033[1;$((f+30))m ${FGNAMES[f]} "
    done
  
    echo -en "\033[0m │"
    echo -e "\033[0m"
  
    ((b<8)) &&
    echo "     ├──────────────────────────────────────────────────────────────────────────┤"
  done
  echo "     └──────────────────────────────────────────────────────────────────────────┘"
}

zigZag(){
  esc=""

  blackf="${esc}[30m";   redf="${esc}[31m";    greenf="${esc}[32m"
  yellowf="${esc}[33m"   bluef="${esc}[34m";   purplef="${esc}[35m"
  cyanf="${esc}[36m";    whitef="${esc}[37m"
  
  blackb="${esc}[40m";   redb="${esc}[41m";    greenb="${esc}[42m"
  yellowb="${esc}[43m"   blueb="${esc}[44m";   purpleb="${esc}[45m"
  cyanb="${esc}[46m";    whiteb="${esc}[47m"

  boldon="${esc}[1m";    boldoff="${esc}[22m"
  italicson="${esc}[3m"; italicsoff="${esc}[23m"
  ulon="${esc}[4m";      uloff="${esc}[24m"
  invon="${esc}[7m";     invoff="${esc}[27m"

  reset="${esc}[0m"

cat << EOF

              ${boldon}${blackf}|              |              |              |              |${reset}
  ${redf}██████${reset}  ${boldon}${redf}██${reset}  ${boldon}${blackf}|${reset}  ${greenf}██████${reset}  ${boldon}${greenf}██${reset}  ${boldon}${blackf}|${reset}  ${yellowf}██████${reset}  ${boldon}${yellowf}██${reset}  ${boldon}${blackf}|${reset}  ${bluef}██████${reset}  ${boldon}${bluef}██${reset}  ${boldon}${blackf}|${reset}  ${purplef}██████${reset}  ${boldon}${purplef}██${reset}  ${boldon}${blackf}|${reset}  ${cyanf}██████${reset}  ${boldon}${cyanf}██${reset} 
  ${redf}██${reset}      ${boldon}${redf}██${reset}  ${boldon}${blackf}|${reset}  ${greenf}██${reset}      ${boldon}${greenf}██${reset}  ${boldon}${blackf}|${reset}  ${yellowf}██${reset}      ${boldon}${yellowf}██${reset}  ${boldon}${blackf}|${reset}  ${bluef}██${reset}      ${boldon}${bluef}██${reset}  ${boldon}${blackf}|${reset}  ${purplef}██${reset}      ${boldon}${purplef}██${reset}  ${boldon}${blackf}|${reset}  ${cyanf}██${reset}      ${boldon}${cyanf}██${reset}  
  ${redf}██ ${reset} ${boldon}${redf}██████${reset}  ${boldon}${blackf}|${reset}  ${greenf}██ ${reset} ${boldon}${greenf}██████${reset}  ${boldon}${blackf}|${reset}  ${yellowf}██ ${reset} ${boldon}${yellowf}██████${reset}  ${boldon}${blackf}|${reset}  ${bluef}██ ${reset} ${boldon}${bluef}██████${reset}  ${boldon}${blackf}|${reset}  ${purplef}██ ${reset} ${boldon}${purplef}██████${reset}  ${boldon}${blackf}|${reset}  ${cyanf}██ ${reset} ${boldon}${cyanf}██████${reset}  
              ${boldon}${blackf}|              |              |              |              |${reset}

EOF
}

colorHash(){
xdef="$HOME/.Xdefaults"

colors=( $( sed -re '/^!/d; /^$/d; /^#/d; s/(\*color)([0-9]):/\10\2:/g;' $xdef | grep 'color[01][0-9]:' | sort | sed  's/^.*: *//g' ) )

echo
for i in {0..7}; do echo -en "\e[$((30+$i))m ${colors[i]} \u2588\u2588 \e[0m"; done
echo
for i in {8..15}; do echo -en "\e[1;$((22+$i))m ${colors[i]} \u2588\u2588 \e[0m"; done
echo -e "\n"
}

if [ $# -lt 1 ]
then
  echo "ERROR: Need argument"
  usage && exit
fi

while getopts "bzh" opt; do
  case $opt in
    b)
      block;;
    z)
      zigZag;;
    h)
      colorHash;;
   \?)
      usage
      ;;
  esac
done

