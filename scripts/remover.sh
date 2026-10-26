#!/bin/bash
set -Eeuo pipefail

source .env

# Цвета для вывода сообщений
NO_COLOR='\033[0m'
OK_COLOR='\033[32;01m'
ERROR_COLOR='\033[31;01m'
WARN_COLOR='\033[33;01m'

# Путь к файлу сервиса
SCRIPT_PATH="$TARGET_PATH/$SCRIPT_NAME"

# Проверяем существование скрипта tuneller.sh и удаляем его
if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "${ERROR_COLOR}Ошибка: Скрипт $SCRIPT_PATH не найден${NO_COLOR}"
    exit 1
fi
if [ -f "$SCRIPT_PATH" ]; then
    sudo rm "$SCRIPT_PATH"
    echo -e "${OK_COLOR}Скрипт $SCRIPT_PATH успешно удалён!${NO_COLOR}"    
fi
