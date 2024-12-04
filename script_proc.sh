#!/bin/bash

function get_info {
    local indent="$1"
    local ppid="$2"
    shift 2
    local pid_array=("$@")

    for pid in "${pid_array[@]}"; do
        echo -n "$indent"
        echo "PPid = $ppid"
        echo -n "$indent"
        echo -e "PID = $pid"
    echo -n "$indent"
    echo "Название запущенной утилиты: $(cat /proc/$pid/comm 2>/dev/null)"
    echo -n "$indent"
    echo "Открытые файловые дескрипторы:"
    echo "$(ls -l /proc/$pid/fd 2>/dev/null| grep -oP '\d+\s+->\s+.+')" > ds
    while IFS= read -r line; do
      echo -n "$indent"
      echo $line
    done <<< ds
        tmp=$(grep -PH "PPid:\s$pid" /proc/*/status)
        arr=()
        while IFS= read -r line; do
            a=$(echo "$line" | grep -oP '/proc/\d+')
            child=$(echo "$a" | grep -oP '\d+')
            if [ -n "$child" ]; then
                arr+=("$child")
            fi
        done <<< "$tmp"
        
        echo -n "$indent"
        echo "PID дочерних процессов:"
        for el in "${arr[@]}"; do
            echo -n "$indent"
            echo "$el"
        done
        
        for el in "${arr[@]}"; do
            get_info "$indent    " "$pid" "$el"
        done
    done
}

indent=""
start_pid=$1
get_info "$indent" "0" "$start_pid"