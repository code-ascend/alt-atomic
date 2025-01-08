#!/bin/bash

echo "Installing GNOME packages"

# Шрифты
cp -r /src/source/font/JetBrainsMono /usr/share/fonts/
cp -r /src/source/font/SanFranciscoProDisplay /usr/share/fonts/

# Обновление шрифтов
fc-cache -fv

# Неожиданно Alt linux в /var/lib/openvpn/dev записывает устройство urandom
# устройства запрещено включать в коммит, только файлы и сим-линки
rm -f /var/lib/openvpn/dev/urandom
ln -s /dev/urandom /var/lib/openvpn/dev/urandom

# Меняем Display manager
#rm /usr/lib/systemd/system/display-manager.service
#ln -s /usr/lib/systemd/system/gdm.service /usr/lib/systemd/system/display-manager.service

# Удаляем неактуальный ярлык
rm -f /usr/share/applications/indexhtml.desktop

# Спрячем приложения
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/htop.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/nvtop.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/org.gnome.Console.desktop

# Звук
systemctl enable pipewire

# включим GDM
systemctl enable gdm

# Синхронизируем конфиги
rsync -av --progress /src/source/GNOME/etc/ /etc/

# Обновление dconf
dconf update

# Включение первоначальной настройки InitialSetupEnable
sed -i '/^\[daemon\]/a InitialSetupEnable=True' /etc/gdm/custom.conf

echo "End installing GNOME packages"