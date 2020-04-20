#!/usr/bin/env sh
# zfs-for-pi
# Clean up build directories in 64-bit userland container
# by andrum99

set -e
set -x

# Get RELEASE and KVERSION strings from version file
. ./version

# Save current working directory
CUR_DIR="$(pwd)"
cd $HOME

sudo rm -rf linux-raspberrypi-kernel_${RELEASE}
sudo rm -rf /lib/modules/${KVERSION}-v8+

cd "${CUR_DIR}"
