#!/bin/bash
# Скрипт для добавления системных групп и пользователей на основе файлов /usr/etc/group и /usr/etc/passwd.
# Обрабатываются только записи с uid (и соответствующим gid) меньше 1000.
# Если пользователь или группа с таким именем уже существуют – запись пропускается.
#
# uid и gid назначаются динамически.
#
# После создания пользователя, если значение домашней директории (home) не равно "/dev/null"
# или "/" и такой директории ещё не существует, она будет создана с назначением владельца.

set -euo pipefail

# Массив групп, в которые нужно добавить пользователей
groups=(docker lxd cuse _xfsscrub fuse libvirt adm wheel uucp cdrom cdwriter audio users video netadmin scanner xgrp camera render usershares)

# Получаем всех пользователей с UID >= 1000, исключая nobody
userarray=($(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd))

# Проверяем, есть ли пользователи
if [[ ${#userarray[@]} -eq 0 ]]; then
    echo "No users with UID >= 1000 found."
    exit 0
fi

# Добавляем пользователей в указанные группы
for user in "${userarray[@]}"; do
    echo "Обрабатываем пользователя $user..."
    for group in "${groups[@]}"; do
        if id -nG "$user" | tr ' ' '\n' | grep -qx "$group"; then
            echo "Пользователь $user уже состоит в группе $group, пропускаем."
        else
            echo "Добавляем пользователя $user в группу $group..."
            usermod -aG "$group" "$user"
        fi
    done
done

# Функция для логгирования
log() {
    echo "[INFO] $*"
}

error() {
    echo "[ERROR] $*" >&2
}

# Проверяем наличие файлов
if [ ! -f /usr/etc/group ]; then
    error "/usr/etc/group не найден!"
    exit 1
fi

if [ ! -f /usr/etc/passwd ]; then
    error "/usr/etc/passwd не найден!"
    exit 1
fi

# Ассоциативный массив для сопоставления gid -> group_name из /usr/etc/group
declare -A gid_to_group

log "Обработка файла /usr/etc/group..."
while IFS=: read -r group_name _ gid members; do
    # Если поле gid не является числом – пропускаем
    if ! [[ "$gid" =~ ^[0-9]+$ ]]; then
        continue
    fi
    # Рассматриваем только системные группы (gid < 1000)
    if [ "$gid" -ge 1000 ]; then
        continue
    fi

    # Запоминаем соответствие gid -> group_name для последующего использования
    gid_to_group["$gid"]="$group_name"

    if getent group "$group_name" >/dev/null 2>&1; then
        log "Группа '$group_name' уже существует – пропускаем создание."
    else
        log "Создаём группу '$group_name'..."
        # Создаём системную группу; система подберёт свободный gid
        groupadd --system "$group_name"
    fi
done < /usr/etc/group

log "Обработка файла /usr/etc/passwd..."
while IFS=: read -r username _ uid gid gecos home shell; do
    # Проверяем, что uid является числом; если нет – пропускаем
    if ! [[ "$uid" =~ ^[0-9]+$ ]]; then
        continue
    fi
    # Рассматриваем только системных пользователей (uid < 1000)
    if [ "$uid" -ge 1000 ]; then
        continue
    fi

    if getent passwd "$username" >/dev/null 2>&1; then
        log "Пользователь '$username' уже существует – пропускаем создание."
    else
        # Определяем имя основной группы для пользователя.
        # Пытаемся по значению поля gid найти группу из /usr/etc/group
        primary_group="${gid_to_group[$gid]:-}"
        if [ -z "$primary_group" ]; then
            # Если соответствующей группы не найдено, используем имя пользователя
            primary_group="$username"
            if ! getent group "$primary_group" >/dev/null 2>&1; then
                log "Основная группа '$primary_group' для пользователя '$username' не найдена – создаём."
                groupadd --system "$primary_group"
            fi
        fi

        log "Создаём пользователя '$username' с основной группой '$primary_group', home='$home', shell='$shell'."
        # Создаём системного пользователя; uid будет назначен системой динамически.
        useradd --system -g "$primary_group" -c "$gecos" -d "$home" -s "$shell" "$username"

        # Если значение домашней директории не '/dev/null' или '/', а такой директории ещё нет, то создаём её.
        if [[ "$home" != "/dev/null" && "$home" != "/" && ! -d "$home" ]]; then
            log "Создаю директорию '$home' для пользователя '$username'."
            mkdir -p "$home"
            chown "$username:$primary_group" "$home"
        fi
    fi
done < /usr/etc/passwd

# Дополнительно: добавляем пользователей в supplementary-группы согласно спискам в /usr/etc/group.
log "Обработка дополнительных членов групп из /usr/etc/group..."
while IFS=: read -r group_name _ _ members; do
    # Если список членов пуст – пропускаем
    [ -z "$members" ] && continue

    # Разбиваем список членов по запятой
    IFS=',' read -ra user_list <<< "$members"
    for member in "${user_list[@]}"; do
        # Удаляем возможные пробелы по краям
        member="$(echo "$member" | xargs)"
        [ -z "$member" ] && continue

        # Проверяем, что пользователь существует и является системным (uid < 1000)
        if user_info=$(getent passwd "$member"); then
            user_uid=$(echo "$user_info" | cut -d: -f3)
            if [ "$user_uid" -ge 1000 ]; then
                continue
            fi
            # Если пользователь уже входит в группу – пропускаем
            if id -nG "$member" | tr ' ' '\n' | grep -qx "$group_name"; then
                log "Пользователь '$member' уже является членом группы '$group_name' – пропускаем."
            else
                log "Добавляем пользователя '$member' в группу '$group_name' как дополнительную."
                usermod -a -G "$group_name" "$member"
            fi
        else
            log "Пользователь '$member' из списка группы '$group_name' не найден в системе – пропускаем."
        fi
    done
done < /usr/etc/group
