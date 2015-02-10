#!/bin/sh
# VirtualBox control handler
# OS X shell context

# Simplifies VBoxHeadless calls (for my use case)

# Usage:
#   vm.sh list          lists all your VMs
#   eval `vm.sh set 1`  set shell context ${VM} for first VM (eval the export)
#   vm.sh start         start the VM indicated by ${VM}
#   vm.sh stop          stop the vm indicated by ${VM}

mkdir -p $HOME/.vmlog
LOGFILE=$HOME/.vmlog/vbox.log
DATEFMT="+%Y-%m-%d %H:%M:%S"

function notice()
{
    printf "%s %s \n" "`date "$DATEFMT"`" "$@" | tee -a $LOGFILE
}


function vmcmd()
{
    local cmd=$1; shift;
    notice "$cmd ${VM} $@"
    case $cmd in
        start) nohup VBoxHeadless -s ${VM} -v config $@ 1>>$LOGFILE 2>>$LOGFILE &;;
        stop) VBoxManage controlvm ${VM} acpipowerbutton $@ 1>>$LOGFILE 2>>$LOGFILE &;;
        res) VBoxManage controlvm ${VM} setvideomodehint $@ 1>>$LOGFILE 2>>$LOGFILE &;;
        *) VBoxManage controlvm ${VM} $cmd $@ 1>>${LOGFILE} 2>>${LOGFILE} &;;
    esac
}


function listvm()
{
    local running=false;
    while getopts :r Opt; do
        case $Opt in
            r) running=true;;
        esac
    done

    case $running in
        false) vm=vms;;
        true)  vm=runningvms;;
    esac

    VBoxManage list $vm
}


function vmstatus()
{
    while read vm; do
        uuid=`echo $vm | getuuid 1`
        eval `VBoxManage showvminfo --machinereadable ${uuid} | grep 'VMState='`
        printf "%s = %s\n" "$vm" "$VMState"
    done
}


function get_vm()
{
    is_integer "$@" && listvm | getuuid "$@" || echo "$@"
}


function is_integer()
{
    printf "%d" "$@" 1>/dev/null 2>/dev/null
    return $?
}


function getuuid()
{ 
    # Get the UUID of a VM specified by line number
    sed -E "$@!d;  s/^(.*)\{(.*)\}$/\2/g; "
}


mode=$1;
shift;

case $mode in
    list)   
        listvm "$@" | vmstatus | cat -n
        ;; # with line numbers
    set)
        echo "export VM=\"`get_vm $@`\""
        ;;
    *) 
        VM=`get_vm ${VM:-NULL}` vmcmd $mode "$@"
        ;;
esac

