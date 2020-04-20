#!/usr/bin/env sh
# Install 64-bit kernel modules for Raspbian, and build 32-bit userland
# by andrum99

# This script must be run under a 32-bit userland on a 32-bit kernel

set -e
set -x

. ./version

# Copy 64-bit kernel modules from where build64.sh left them
cd /
sudo tar xvf $HOME/64-bit-zfs-modules-${KVERSION}-v8+.tar.gz

# build 32-bit part of zfs-linux

sudo apt update
sudo apt upgrade -y

sudo apt install raspberrypi-kernel-headers

# https://github.com/zfsonlinux/zfs/wiki/Building-ZFS
sudo apt install -y autoconf automake libtool gawk alien fakeroot ksh libssl-dev
sudo apt install -y zlib1g-dev uuid-dev libattr1-dev libblkid-dev libselinux-dev libudev-dev
sudo apt install -y libacl1-dev libaio-dev libdevmapper-dev libelf-dev
sudo apt install -y python3 python3-dev python3-setuptools python3-cffi

cd $HOME/linux-raspberrypi-kernel_${RELEASE}/zfs

make clean || true
make distclean || true
sudo rm -rf bin

./autogen.sh
autoreconf --install --force
./configure

make -s -j6
sudo make install

# Update kernel config
sudo ldconfig
sudo depmod -a

# Install zfsutils-linux package from buster-backports
wget -q -O - https://ftp-master.debian.org/keys/archive-key-10.asc | sudo apt-key add -
echo "deb http://deb.debian.org/debian/ buster-backports main contrib" | sudo tee /etc/apt/sources.list.d/debian.list
sudo apt update
sudo apt install -y zfsutils-linux

# Make a tarball of the 32-bit kernel modules
tar -cvzf $HOME/32-bit-zfs-modules-${KVERSION}-v7l+.tar.gz /lib/modules/${KVERSION}-v7l+/extra

# Optional ZFS packages from buster-backports
# sudo apt install zfs-auto-snapshot zfs-zed zfssnap libguestfs-zfs libvirt-daemon-driver-storage-zfs zfs-initramfs

# Optional ZFS development packages from buster-backports
# sudo apt install golang-go-zfs-dev python3-pyzfs pyzfs-doc
