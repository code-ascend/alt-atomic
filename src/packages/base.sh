#!/bin/bash

echo "Installing base packages"

apt-get install -y \
    zsh \
    golang \
    zram-generator \
    inxi \
    firmware-linux \
    jq \
    yq \
    fprintd \
    qemu-guest-agent \
    spice-vdagent \
    bash-completion \
    zsh-completions \
    starship \
    htop \
    notify-send \
    nvtop \
    distrobox \
    flatpak \
    docker-engine \
    tzdata \
    fastfetch \
    podman \
    mount \
    libvirt \
    lxd \
    eza \
    bluez \
    btrfs-progs \
    kbd \
    kbd-data \
    man \
    mc \
    nano \
    passwd \
    bubblewrap \
    efivar \
    shim-unsigned  \
    libselinux \
    policycoreutils \
    shim-signed \
    efitools \
    glibc-utils \
    su \
    sudo \
    virtiofsd \
    which \
    ostree \
    libostree-devel \
    fuse-overlayfs \
    git \
    wget \
    composefs \
    skopeo \
    efibootmgr \
    grub \
    grub-efi \
    grub-btrfs \
    containers-common \
    curl \
    losetup \
    build-essential \
    unzip \
    util-linux \
    coreutils \
    systemd \
    systemd-devel \
    dosfstools \
    e2fsprogs \
    iputils \
    NetworkManager \
    attr \
    sfdisk \
    rust \
    pkg-config \
    openssl \
    openssl-devel \
    glib2 \
    glib2-devel \
    libgio \
    libgio-devel \
    dracut \
    kernel-image-6.12 \
    kernel-modules-drm-6.12 \
    rsync \
    plymouth \
    mesa-dri-drivers \
    glxinfo \
    chrony

echo "End installing base packages"