#!/bin/bash

source .env

# Цвета для вывода сообщений
NO_COLOR='\033[0m'
OK_COLOR='\033[32;01m'
ERROR_COLOR='\033[31;01m'
WARN_COLOR='\033[33;01m'

# Сохраняем текущую директорию
CURRENT_DIR=$(pwd)

# Сохраняем текущего пользователя
CURRENT_USER=$(whoami)

mkdir -p $HOME/.config/systemd/user

# Путь к файлу сервиса
SERVICE_PATH="$HOME/.config/systemd/user/$SCRIPT_NAME.service"

# Проверяем существование скрипта gpbackup.sh
TUNNEL_SCRIPT="$TARGET_PATH/$SCRIPT_NAME"
if [ ! -f "$TUNNEL_SCRIPT" ]; then
    echo -e "${ERROR_COLOR}Ошибка: Скрипт $TUNNEL_SCRIPT не найден${NO_COLOR}"
    exit 1
fi
if [ ! -x "$TUNNEL_SCRIPT" ]; then
    sudo chmod +x "$TUNNEL_SCRIPT"
fi

# Проверяем, существует ли файл сервиса
if [ -f "$SERVICE_PATH" ]; then
    echo -e "${WARN_COLOR}Файл $SERVICE_PATH уже существует. Перезаписать? (y/n)${NO_COLOR}"
    read -r OVERWRITE
    if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
        echo -e "${OK_COLOR}Скрипт завершён без изменений${NO_COLOR}"
        exit 0
    fi
    sudo rm "$SERVICE_PATH"
fi

echo -e "${OK_COLOR}Создаём файл $SERVICE_PATH...${NO_COLOR}"

# Создаём файл сервиса
cat << EOF | tee "$SERVICE_PATH"
[Unit]
Description=SSH Proxy Tunnel
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=$TUNNEL_SCRIPT
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

# Проверка успешности создания файла
if [ $? -ne 0 ] || [ ! -s "$SERVICE_PATH" ]; then
    echo -e "${ERROR_COLOR}Ошибка: Не удалось создать $SERVICE_PATH${NO_COLOR}"
    exit 1
fi

# Проверка синтаксиса файла
if ! systemd-analyze verify "$SERVICE_PATH"; then
    echo -e "${ERROR_COLOR}Ошибка: Неверный синтаксис в $SERVICE_PATH${NO_COLOR}"
    rm "$SERVICE_PATH"
    exit 1
fi

# Устанавливаем корректные права доступа
chmod 644 "$SERVICE_PATH"

# Перезагружаем systemd
systemctl --user daemon-reload
systemctl --user enable --now $SCRIPT_NAME.service

# Проверяем статус сервиса
systemctl --user status $SCRIPT_NAME.service

journalctl --user -u $SCRIPT_NAME.service -f

echo -e "Сервис создан, его состояние выведено выше."
echo -e "Для остановки сервиса использовать команду systemctl --user stop $SCRIPT_NAME.service"
echo -e "Для отключения автозапуска - systemctl --user disable --now $SCRIPT_NAME.service"
