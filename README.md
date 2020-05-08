# zfs-for-pi
ZFS for the Raspberry Pi.

Based on Alexey Tsarev's gist at https://gist.github.com/Alexey-Tsarev/d5809e353e756c5ce2d49363ed63df35

This repository contains build scripts to allow building ZFS on Raspbian. It builds ZFS both as 64-bit modules and as 32-bit modules. It is recommended that under normal circumstances your system should use the 64-bit kernel only for ZFS. The reason the 32-bit kernel modules are built and installed is that the rest of the 32-bit build is required because Raspbian has a 32-bit userland, and the easiest way to get those parts is to simply build the whole 32-bit thing.

**N.B.** When the Raspbian kernel gets updated, you must manually update these build scripts to point to the relevant source archive. This is now done using the `version` file. There are two variables that need changed - `RELEASE` specifies the end of the release tag (e.g. 1.20200212-1), which can be found at https://github.com/raspberrypi/linux/releases, the other is `KVERSION` which specifies the kernel version (e.g. 4.19.97), which can be found by examining the tarball using e.g. `tar -tvf raspberrypi-kernel_1.20200212-1.tar.gz`.

Bear in mind that updating your Pi using `apt` or `apt-get` will sometimes upgrade the kernel, which will cause ZFS to not load, unless you then build the modules using these scripts. You may find it useful to put the kernel packages on hold like this:

~~~~
sudo apt-mark hold raspberrypi-bootloader
sudo apt-mark hold raspberrypi-kernel
sudo apt-mark hold raspberrypi-kernel-headers
~~~~

To remove hold:

~~~~
sudo apt-mark unhold raspberrypi-bootloader
sudo apt-mark unhold raspberrypi-kernel
sudo apt-mark unhold raspberrypi-kernel-headers
~~~~

## Procedure
1. Switch to a 64-bit kernel
2. Install the 64-bit systemd-nspawn from sakaki (see https://www.raspberrypi.org/forums/viewtopic.php?f=63&t=232417&p=1566755&hilit=zfs#p1566212)
3. Run build64.sh within the 64-bit systemd-nspawn container (ds64-shell)
4. Exit from the 64-bit userland.
5. Run build64_part2.sh within the normal 32-bit userland (still on the 64-bit kernel).
6. Switch to a 32-bit kernel
7. Run build32.sh
8. Switch to a 64-bit kernel
9. `sudo depmod -a`
10. `sudo modprobe zfs`
11. Profit

Note: Getting the ZFS modules to load at boot time seems to be hit and miss - see https://github.com/zfsonlinux/zfs/issues/8885. In particular, if you have zpool(s) which consists of only files, not disks, then the pool(s) will fail to mount on boot. A quick and dirty workaround is to simply force the loading of the ZFS modules at boot time by adding `zfs` to `/etc/modules-load.d/modules.conf`.

Also, this is just a stopgap until Raspbian supports a full 64-bit userland, at which point we will be able to use the stock Debian packages without modification - including zfs-dkms.
