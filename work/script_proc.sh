#!/bin/bash


get_process_info() {
    local pid="$1"
    if [ ! -d "/proc/$pid" ]; then
        echo "Процесс с PID $pid не найден."
        return
    fi

    local name=$(cat /proc/$pid/comm)
    echo "Процесс c PID - $pid: $name "

    echo "Открытые файловые дескрипторы:"
    ls -l /proc/$pid/fd | awk '{print $9,$10,$11}'

    echo "Дочерние процессы:"
    local children_path="/proc/$pid/task/$pid/children"

    if [ -e "$children_path" ]; then
        local children=$(cat "$children_path")

        if [ -z "$children" ]; then
            echo "Нет дочерних процессов."
        else
            for child in $children; do
                get_process_info "$child"
            done
        fi
    else
        echo "Не удалось получить дочерние процессы."
    fi
}

get_process_info "$1"
