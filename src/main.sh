#!/bin/bash

# любая ошибка остановит выполнение
set -e

echo "Running main.sh..."

# Базовые пакеты для работы системы
./packages/apt_prepare.sh
./packages/base.sh
./packages/DE/gnome.sh
./packages/apt_ending.sh

# Настройка
./configuration/branding.sh
./configuration/settings.sh
./configuration/kernel.sh
./make/zstd.sh
./make/cargo.sh
./make/bootupd.sh
./make/bootc.sh
./configuration/ostree.sh

echo "All scripts executed successfully."