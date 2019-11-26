# zfs-for-pi
ZFS for the Raspberry Pi

Based on Alexey Tsarev's gist at https://gist.github.com/Alexey-Tsarev/d5809e353e756c5ce2d49363ed63df35

This repository contains build scripts to allow building ZFS on Raspbian. It builds ZFS both as 64-bit modules and as 32-bit modules. It is recommended that under normal circumstances your system should use the 64-bit kernel only. The reason the 32-bit kernel modules are built and installed is that the rest of the 32-bit build is required because Raspbian has a 32-bit userland, and the easiest way to get those parts is to simply build the whole 32-bit thing.

## Procedure
1. Switch to a 64-bit kernel
2. Install the 64-bit systemd-nspawn from sakaki (see https://www.raspberrypi.org/forums/viewtopic.php?f=63&t=232417&p=1566755&hilit=zfs#p1566212)
3. Run build64.sh within the 64-bit systemd-nspawn container
4. Switch to a 32-bit kernel
5. Run build32.sh

N.B. This is just a stop-gap until Raspbian supports a full 64-bit userland.
