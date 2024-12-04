#!/bin/sh

# Проверка наличия аргумента
if [ -z "$1" ]; then
    echo "Usage: $0 <target-pid>"
    exit 1
fi

TARGET_PID=$1

# Проверка, смонтирован ли procfs
if ! mount | grep -q "/proc"; then
    echo "procfs is not mounted. Mounting it..."
    sudo mount -t procfs proc /proc || { echo "Failed to mount procfs"; exit 1; }
fi

# Функция для вывода данных о процессе
process_info() {
    local pid=$1
    local indent=$2

    # Проверка, существует ли процесс
    if [ ! -d /proc/$pid ]; then
        echo "${indent}Process $pid not found"
        return
    fi

    # Название процесса
    local cmd=$(cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ' || echo "N/A")
    
    # Открытые файловые дескрипторы
    local fds=$(ls /proc/$pid/fd 2>/dev/null | wc -l || echo "N/A")

    # Дочерние процессы
    local children=$(pgrep -P $pid)

    echo "${indent}PID: $pid"
    echo "${indent}  Command: $cmd"
    echo "${indent}  Open File Descriptors: $fds"
    echo "${indent}  Child Processes: $children"

    # Рекурсивно обрабатывать дочерние процессы
    for child in $children; do
        process_info $child "${indent}  "
    done
}

# Запуск обработки целевого PID
process_info $TARGET_PID ""