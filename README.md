# UbuntuZFSRoot
Modified set of scripts to automatically install ZFS root on Intel NUC w/ L2ARC

This guide will describe the process to automatically install Ubuntu 18.04 with a full ZFS root on the following device:

- Intel NUC with one SATA and one Intel Optane 16GB PCIe M.2.

The routine is a series of two scripts. The first uses a modified version of the ZOL ZFS root install guide. The second runs inside of a chroot environment to finalize the installation and configuration prior to reboot.

Note: This routine wipes out all information on both the SATA device and the Optane M.2. Please be mindful of this when running or modifying the script.
