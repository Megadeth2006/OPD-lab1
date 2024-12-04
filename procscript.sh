process_info() {
    local pid=$1
    local indent=$2

    # Проверка, существует ли процесс
    if [ ! -d /proc/$pid ]; then
        echo "${indent}Process $pid not found"
        return
    fi

    # Название процесса (cmdline)
    local cmd=$(cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ' || echo "N/A")
    
    # Открытые файловые дескрипторы
    local fds=$(ls /proc/$pid/fd 2>/dev/null | wc -l || echo "N/A")

    # Дочерние процессы (анализ через /proc/<pid>/status)
    local children=$(for child in $(ls /proc | grep -E '^[0-9]+$'); do
        if [ "$(cat /proc/$child/status 2>/dev/null | grep '^PPid:' | awk '{print $2}')" = "$pid" ]; then
            echo $child
        fi
    done)

    # Вывод информации о процессе
    echo "${indent}PID: $pid"
    echo "${indent}  Command: $cmd"
    echo "${indent}  Open File Descriptors: $fds"
    echo "${indent}  Child Processes: $children"

    # Рекурсивный вызов для дочерних процессов
    for child in $children; do
        process_info $child "${indent}  "
    done
}

# Запуск обработки целевого PID
process_info $TARGET_PID "$1"