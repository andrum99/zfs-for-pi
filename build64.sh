#!/usr/bin/env sh
# Build script for ZFS on Raspberry Pi
# by andrum99
# Based on https://gist.github.com/Alexey-Tsarev/d5809e353e756c5ce2d49363ed63df35

# This script must be run in a 64-bit userland on a Raspberry Pi running Raspbian. For example, under the 64-bit systemd-nspawn
# container provided by sakaki - see https://www.raspberrypi.org/forums/viewtopic.php?f=63&t=232417&p=1566755&hilit=zfs#p1566212

set -e
set -x

. ./version
CUR_DIR="$(pwd)"
cd $HOME

# Install required packages
sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential bison flex bc libssl-dev wget git

# Build Linux kernel. Most of this we don't use - we just need the
# kernel headers and the Module.symvers

wget https://github.com/raspberrypi/linux/archive/raspberrypi-kernel_${RELEASE}.tar.gz
tar -xvf raspberrypi-kernel_${RELEASE}.tar.gz
cd linux-raspberrypi-kernel_${RELEASE}
KERNEL=kernel8
make bcm2711_defconfig
make -j6
make modules_prepare
make modules -j6

# build ZFS 64-bit modules

if [ ! -d zfs ]; then
    # https://github.com/zfsonlinux/zfs/wiki/Building-ZFS
    sudo apt install -y autoconf automake libtool gawk alien fakeroot ksh
    sudo apt install -y zlib1g-dev uuid-dev libattr1-dev libblkid-dev libselinux-dev libudev-dev
    sudo apt install -y libacl1-dev libaio-dev libdevmapper-dev libelf-dev
    sudo apt install -y python3 python3-dev python3-setuptools python3-cffi

    #sudo apt install -y linux-headers-$(uname -r)
    #sudo apt install raspberrypi-kernel-headers

    git clone https://github.com/zfsonlinux/zfs.git
fi

cd zfs
git checkout .
git checkout zfs-0.8.3
#git pull
#git branch

make clean || true
make distclean || true

./autogen.sh
autoreconf --install --force
./configure --with-linux=$HOME/linux-raspberrypi-kernel_${RELEASE}

make -s -j6
sudo make install

sudo mkdir -p /lib/modules/${KVERSION}-v8+/extra
sudo mv /lib/modules/${KVERSION}-v8/extra /lib/modules/${KVERSION}-v8+/extra
tar -cvzf $HOME/64-bit-zfs-modules-${KVERSION}-v8+.tar.gz /lib/modules/${KVERSION}-v8+/extra
echo "Now exit the 64-bit userland, back to 32-bit userland (staying on 64-bit kernel) and run build64_part2.sh"

cd "${CUR_DIR}"
