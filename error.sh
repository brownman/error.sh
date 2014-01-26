#!/bin/bash
#script written by Ofer Shaham
#26.1.2014
#dependencies: bash, gxmessage, libnotify, xsel, vim

notify-send "debug or undebug ?"
export file_logger=/tmp/logger.txt

#echo -n '' > $file_logger
if [ -f "$file_logger" ];then
    rm $file_logger
else
    touch $file_logger
fi

export path=`pwd`

if [ "$1" ];then
    script="$path/$1"

    echo "script: $script"
    if [ -f "$script" ];then
        echo "script exist, continue..."

    else
        echo "no such script"
        exit
    fi


    if [ "$2" ];then
        shift
        args=( "$@" )
    fi
else
    echo 'supply a script to wrap'
    exit
fi

print_line() { 
  hr='----------------------------------------------------------------'
    printf '%s\n' "${hr:0:${COLUMNS:-$(tput cols)}}"
}

blue()       { echo -e "\x1B[01;30m[*]\x1B[0m $@"; }
red() { echo -e "\x1B[01;31m[*]\x1B[0m $@"; }
green()         { echo -e "\x1B[01;32m[*]\x1B[0m $@"; }

print_error(){
    red "print error:"
    echo "$@"
}
str_to_arr(){
    #depend on: arr
    #blue 'str_to_arr'
    local str="$1"
    local delimeter=${2-:}
    IFS=$delimeter read -a arr <<< "$str"
    #result: arr
}


use_error(){
    blue 'use_error()'
    local line="$1"
    arr=()
    local str=`echo $line | sed 's/line /+/g'`
    #    echo "$str"
    str_to_arr "$str"
    #we have: arr
    echo "ARR"

    exe="${arr[0]}"
    line="${arr[1]}"
    error="${arr[2]}"
    error_code="${arr[3]}"



    #IFS=\s
    #echo "${arr[@]}" > /tmp/error.txt
    notify-send "$error" "$error_code"
    printf "%s\n" "${arr[@]}" > /tmp/error.txt
    
    
    #for debugging purpose:
    #cat -n /tmp/error.txt

    echo "vi $exe $line" | xsel --clipboard
    sleep 1
    green 'your clipboard has been updated!'
}
try(){
    blue 'try()'
    #echo something >> $file_logger
    #    $( exec "$script" 2>&1 1>$file_logger )
    eval "$script" 2>$file_logger
    local error_code=$?
    if [ "$error_code" -eq 0   ];then
        print_line
        green "no error_code"
    else
        print_line
        red "error_code: $error_code"
    fi

}
show_log(){
    blue  'show_log()' #
    #    exit
    #    cmd="$script ${args[@]}" 
    #    echo "cmd: $cmd"

    #    $(eval "$cmd") 2> $file_logger 
    #
    if [ -f "$file_logger" ];then
        if [ -s "$file_logger" ];then
            red "logger is not empty"
            echo Press Enter!
            read
            line=`cat $file_logger`
            print_error "$line"
            use_error "$line"
            #   use_error "$line"
        else
            green "logger is empty"
            blue "$file_logger:"
            echo
        fi
    else
        red 'no such file'
    fi

}

breakpoint(){
    echo breakpoint!
}
steps(){
    blue "run()"
    green "steps: 1.try   2.show_log"
    try 
    show_log

}

#native "logger: $file_logger"
steps
trap breakpoint ERR
