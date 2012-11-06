
#!/bin/bash  
# AVI or any video 2 DVD iso Script  
# DvdAuthor 7 and up needs this
export VIDEO_FORMAT=NTSC
# Change to "ntsc" if you'd like to create NTSC disks  
format="ntsc"  
  
# Check we have enough command line arguments  
if [ $# != 1 ]  
then  
    echo "Usage: $0 <input file>"  
    exit  
fi  
  
# Check for dependencies  
missing=0  
dependencies=( "mencoder" "ffmpeg" "dvdauthor" "mkisofs" )  
for command in ${dependencies[@]}  
do  
    if ! command -v $command &>/dev/null  
    then  
        echo "$command not found"  
        missing=1  
    fi  
done  
  
if [ $missing = 1 ]  
then  
    echo "Please install the missing applications and try again"  
    exit  
fi  
  
function emphasise() {  
    echo ""  
    echo "********** $1 **********"  
    echo ""  
}  
  
# Check the file exists  
input_file=$1  
if [ ! -e "$input_file" ]  
then  
    echo "Input file not found"  
    exit  
fi  
  
emphasise "Converting AVI to MPG"  
  
ffmpeg -i "$1" -y -target ${format}-dvd -sameq -aspect 16:9 "$1.mpg"
  
if [ $? != 0 ]  
then  
    emphasise "Conversion failed"  
    exit  
fi  
  
emphasise "Creating DVD contents"  

dvdauthor --title -o dvd -f "$1.mpg"
first=$?  
dvdauthor -o dvd -T  
second=$?  
  
if [ $first != 0 || $second != 0 ]  
then  
    emphasise "DVD Creation failed"  
    exit  
fi  
  
emphasise "Creating ISO image"  
  
mkisofs -dvd-video -o dvd.iso dvd/  
  
if [ $? != 0 ]  
then  
    emphasise "ISO Creation failed"  
    exit  
fi  
  
# Everything passed. Cleanup  
rm -f "$1.mpg"
rm -rf dvd/  
  
emphasise "Success: dvd.iso image created" 
