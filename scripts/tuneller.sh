#!/bin/bash
set -Eeuo pipefail

source .env

# Цвета для вывода сообщений
NO_COLOR='\033[0m'
OK_COLOR='\033[32;01m'
ERROR_COLOR='\033[31;01m'
WARN_COLOR='\033[33;01m'

# Сохраняем текущего пользователя
CURRENT_USER=$(whoami)

# Путь к файлу сервиса
SCRIPT_PATH="$TARGET_PATH/$SCRIPT_NAME"

# Проверяем существование скрипта tuneller.sh
if [ -f "$SCRIPT_PATH" ]; then
    echo -e "${ERROR_COLOR}Ошибка: Скрипт $SCRIPT_PATH уже существует:${NO_COLOR}"
    cat "$SCRIPT_PATH"
    echo -e "${OK_COLOR}Удалить файл можно командой make clean...${NO_COLOR}"
    exit 1
fi

echo -e "${OK_COLOR}Создаём файл $SCRIPT_PATH...${NO_COLOR}"

# Создаём файл сервиса
cat << EOF | sudo tee "$SCRIPT_PATH"
#!/bin/bash
set -Eeuo pipefail

PID_FILE="/tmp/ssh-proxy-${LOCAL_PORT}.pid"
LOG_FILE="/tmp/ssh-proxy-${LOCAL_PORT}.log"

# Проверка локального порта
if ss -lntH "sport = :${LOCAL_PORT}" | grep -q .; then
    echo "Порт ${LOCAL_PORT} уже занят. Возможно, туннель запущен."
    exit 1
fi

# Запуск SSH-туннеля в фоне
/usr/bin/ssh \
    -i "$SSH_KEY" \
    -p "$SSH_PORT" \
    -N \
    -o ExitOnForwardFailure=yes \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -o StrictHostKeyChecking=yes \
    -L "127.0.0.1:${LOCAL_PORT}:127.0.0.1:${REMOTE_PORT}" \
    "${SSH_USER}@${SSH_HOST}"

# Проверяем, что локальный порт появился
for _ in {1..5}; do
    if ss -lntH "sport = :${LOCAL_PORT}" | grep -q .; then
        echo "SSH-туннель запущен: 127.0.0.1:${LOCAL_PORT}"
        exit 0
    fi
    sleep 1
done

echo "Ошибка: SSH-туннель не появился. Подробности: /tmp/ssh-proxy-${LOCAL_PORT}.log"
exit 1
EOF

# Проверка успешности создания файла
if [ $? -ne 0 ] || [ ! -s "$SCRIPT_PATH" ]; then
    echo -e "${ERROR_COLOR}Ошибка: Не удалось создать $SCRIPT_PATH${NO_COLOR}"
    exit 1
fi

# Проверка синтаксиса файла
if ! sudo bash -n "$SCRIPT_PATH"; then
    echo -e "${ERROR_COLOR}Ошибка: Неверный синтаксис в $SCRIPT_PATH${NO_COLOR}"
    sudo rm -f "$SCRIPT_PATH"
    exit 1
fi

# Устанавливаем корректные права доступа
sudo chmod +x "$SCRIPT_PATH"

echo -e "${OK_COLOR}$SCRIPT_PATH успешно создан и доступен для выполнения командой $SCRIPT_NAME. ${NO_COLOR}"
