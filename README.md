# UbuntuZFSRoot
Modified set of scripts to automatically install ZFS root on Intel NUC w/ L2ARC

This guide will describe the process to automatically install Ubuntu 18.04 with a full ZFS root on the following device:

- Intel NUC with one SATA and one Intel Optane 16GB PCIe M.2.

The routine is a series of two scripts. The first uses a modified version of the ZOL ZFS root install guide. The second runs inside of a chroot environment to finalize the installation and configuration prior to reboot.

Note: This routine wipes out all information on both the SATA device and the Optane M.2. Please be mindful of this when running or modifying the script.

Instructions:

1) Create a Ubuntu LiveUSB and place all of the script and config files in a new folder of your choice on the device.
2) Modify the script to reflect the correct underlying disk ID's (e.g. /dev/sda).
3) Run zfs_install.sh under the scripts folder on the USB drive.
4) Once zfs_install.sh has completed, run final_install.sh. Reboot the system.
5) Enjoy a fully functional Ubuntu system with ZFS root (rpool) and an L2ARC.
