#!/bin/bash
# init
# Created 6-16-19 by evansi @ WWT

apt-add-repository universe
apt update
dd if=/dev/zero of=/dev/sda bs=512 count=1 conv=notrunc
apt install --yes debootstrap gdisk zfs-initramfs openssh-server
sgdisk --zap-all /dev/sda
apt install zfs-initramfs gdisk debootstrap
sgdisk     -n2:1M:+512M   -t2:EF00 /dev/sda
sgdisk     -n3:0:+512M    -t3:BF01 /dev/sda
sgdisk     -n4:0:0        -t4:BF01 /dev/sda
zpool create -f -o ashift=12 -d \
      -o feature@async_destroy=enabled \
      -o feature@bookmarks=enabled \
      -o feature@embedded_data=enabled \
      -o feature@empty_bpobj=enabled \
      -o feature@enabled_txg=enabled \
      -o feature@extensible_dataset=enabled \
      -o feature@filesystem_limits=enabled \
      -o feature@hole_birth=enabled \
      -o feature@large_blocks=enabled \
      -o feature@lz4_compress=enabled \
      -o feature@spacemap_histogram=enabled \
      -o feature@userobj_accounting=enabled \
      -O acltype=posixacl -O canmount=off -O compression=lz4 -O devices=off \
      -O normalization=formD -O relatime=on -O xattr=sa \
      -O mountpoint=/ -R /mnt \
      bpool /dev/sda3
zpool create -f -o ashift=12 \
      -O acltype=posixacl -O canmount=off -O compression=lz4 \
      -O dnodesize=auto -O normalization=formD -O relatime=on -O xattr=sa \
      -O mountpoint=/ -R /mnt \
      rpool /dev/sda4
zfs create -o canmount=off -o mountpoint=none rpool/ROOT
zfs create -o canmount=off -o mountpoint=none bpool/BOOT
zfs create -o canmount=noauto -o mountpoint=/ rpool/ROOT/ubuntu
zfs mount rpool/ROOT/ubuntu
zfs create -o canmount=noauto -o mountpoint=/boot bpool/BOOT/ubuntu
zfs mount bpool/BOOT/ubuntu
zfs create                                 rpool/home
zfs create -o mountpoint=/root             rpool/home/root
zfs create -o canmount=off                 rpool/var
zfs create -o canmount=off                 rpool/var/lib
zfs create                                 rpool/var/log
zfs create                                 rpool/var/spool
zfs create -o com.sun:auto-snapshot=false  rpool/var/cache
zfs create -o com.sun:auto-snapshot=false  rpool/var/tmp
chmod 1777 /mnt/var/tmp
zfs create                                 rpool/var/games
debootstrap bionic /mnt
zfs set devices=off rpool

cat >> /mnt/etc/netplan/eno1.yaml << EOF

network:
 version: 2
 renderer: networkd
 ethernets:
   eno1:
     dhcp4: yes
     dhcp6: no
EOF

cat <<EOF >> /mnt/etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu bionic main universe
deb-src http://archive.ubuntu.com/ubuntu bionic main universe

deb http://security.ubuntu.com/ubuntu bionic-security main universe
deb-src http://security.ubuntu.com/ubuntu bionic-security main universe

deb http://archive.ubuntu.com/ubuntu bionic-updates main universe
deb-src http://archive.ubuntu.com/ubuntu bionic-updates main universe
EOF

mount --rbind /dev  /mnt/dev
mount --rbind /proc /mnt/proc
mount --rbind /sys  /mnt/sys
mkdir /mnt/etc/scripts
chmod -R 777 /mnt/etc/scripts
cp ./zfs-import-bpool.service /mnt/etc/scripts
cp ./zfs.conf /mnt/etc/modprobe.d
cp ./final_install.sh /mnt/etc/scripts
cp -r ./packages /mnt/etc/scripts
cp ./zfs.conf /etc/modprobe.d
chroot /mnt /bin/bash --login



