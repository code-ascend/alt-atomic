#!/usr/bin/bash


echo "Installing Brew"

set -xeou pipefail

cd /tmp
mkdir -p /home/linuxbrew/

# Переменная которая говорит что мы внутри контейнера
touch /.dockerenv

# Brew Install
curl --retry 3 -Lo /tmp/brew-install https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
chmod +x /tmp/brew-install
/tmp/brew-install
tar --zstd -cvf /usr/share/homebrew.tar.zst /home/linuxbrew/.linuxbrew

echo "End installing Brew"