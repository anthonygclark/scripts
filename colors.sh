#!/bin/bash
#------~------~
# Anthony Clark
#------~------~
# Color script. Functionality taken from others.

function usage(){
cat << EOF
Usage $0:
  -b Show color block
  -z Show color zigzags
  -h Show color hashes
  -p Show color pipes
  -d Show color dots
EOF
}


function block(){
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


function zigZag(){
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


function colorHash()
{
    xdef="$HOME/.Xresources"
    
    colors=( $( sed -re '/^!/d; /^$/d; /^#/d; s/(\*color)([0-9]):/\10\2:/g;' $xdef | grep 'color[01][0-9]:' | sort | sed  's/^.*: *//g' ) )
    
    echo
    for i in {0..7}; do echo -en "\e[$((30+$i))m ${colors[i]} \u2588\u2588 \e[0m"; done
    echo
    for i in {8..15}; do echo -en "\e[1;$((22+$i))m ${colors[i]} \u2588\u2588 \e[0m"; done
    echo -e "\n"
}


function pipes() 
{
    declare -i f=75 s=13 r=2000 t=0 c=1 n=0 l=0
    declare -ir w=$(tput cols) h=$(tput lines)
    declare -i x=$((w/2)) y=$((h/2))
    declare -ar v=( [00]="\x83" [01]="\x8f" [03]="\x93"
            [10]="\x9b" [11]="\x81" [12]="\x93"
            [21]="\x97" [22]="\x83" [23]="\x9b"
            [30]="\x97" [32]="\x8f" [33]="\x81" )

    tput smcup
    tput reset
    tput civis
    while ! read -t0.0$((1000/$f)) -n1; do
        # New position:
        (($l%2)) && ((x+=($l==1)?1:-1))
        ((!($l%2))) && ((y+=($l==2)?1:-1))

        # Loop on edges (change color on loop):
        ((c=($x>$w || $x<0 || $y>$h || $y<0)?($RANDOM%7-1):$c))
        ((x=($x>$w)?0:(($x<0)?$w:$x)))
        ((y=($y>$h)?0:(($y<0)?$h:$y)))

        # New random direction:
        ((n=$RANDOM%$s-1))
        ((n=($n>1||$n==0)?$l:$l+$n))
        ((n=($n<0)?3:$n%4))

        # Print:
        tput cup $y $x
        echo -ne "\033[1;3${c}m\xe2\x94${v[$l$n]}"
        (($t>$r)) && tput reset && tput civis && t=0 || ((t++))
        l=$n
    done
    tput rmcup
}


function dots()
{
    echo

    for i in {0..7}; 
    do 
        echo -en "\e[0;3${i}m⣿⣿⣿⣿\e[0m"
    done

    echo

    for i in {0..7}; do
        echo -en "\e[0;3${i}m⣿⣿⣿⣿\e[0m"
    done

    echo

    for i in {0..7}; 
    do 
        echo -en "\e[1;3${i}m⣿⣿⣿⣿\e[0m"
    done

    echo
    echo
}


if [ $# -lt 1 ]
then
    echo "ERROR: Need argument"
    usage ; exit
fi


while getopts "bzhpd" opt; do
    case $opt in
        b)
            block;;
        z)
            zigZag;;
        h)
            colorHash;;
        p)
            pipes;;
        d)
            dots;;
        \?)
            usage
            ;;
    esac
done

