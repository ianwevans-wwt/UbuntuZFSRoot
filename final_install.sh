#!/bin/bash
# init
# Created 6-16-19 by evansi @ WWT
 
ln -s /proc/self/mounts /etc/mtab
apt update && install -y nano
LANG=en_US.UTF-8 locale-gen --purge en_US.UTF-8
apt install --yes --no-install-recommends linux-image-generic
apt install --yes zfs-initramfs
apt install dosfstools
mkdosfs -F 32 -s 1 -n EFI /dev/sda2
mkdir /boot/efi
echo PARTUUID=$(blkid -s PARTUUID -o value \
     /dev/sda2) \
     /boot/efi vfat nofail,x-systemd.device-timeout=1 0 1 >> /etc/fstab
mount /boot/efi
apt install --yes grub-efi-amd64-signed shim-signed
# Add optional packages here. This example is being built out for K12 students.
apt install --yes nano
apt install --yes edubuntu-desktop
apt install --yes xubuntu-desktop
apt install --yes gdebi-core wget
apt install --yes msttcorefonts
apt install --yes gcompris
apt install --yes chromium-browser
apt install --yes hunspell-es
apt install --yes hypehn-es
apt install --yes aspell-es
apt install --yes language-pack-es
apt install --yes qalculate-gtk
apt install --yes calibre
apt install --yes pdfmod
apt install --yes scribus
apt install --yes codeblocks
apt install --yes ninja-ide
apt install --yes scratch
apt install --yes kdeedu
apt install --yes tuxpaint
apt install --yes tuxtype
apt install --yes blender
apt install --yes gimp
apt install --yes lmms
apt install --yes synaptic
apt install --yes qcalculate
apt install --yes libreoffice-l10n-es
apt install --yes mypaint
apt install --yes default-jre
apt install --yes default-jdk
apt install --yes arduino-core
apt install --yes freecad
apt install --yes desktop-file-utils
apt-install --yes snap
snap install code --classic
snap install vlc
apt install --yes browser-plugin-vlc
apt install --yes exfat-utils
apt install --yes fonts-lyx
apt install --yes xfce4
apt install --yes dconf-tools
apt install --yes libglib2.0-bin
apt install --yes gdm3
apt-install --yes gnome-common
apt-install --yes xscreensaver xscreensaver-gl-extra xscreensaver-data-extra
wget http://archive.ubuntu.com/ubuntu/pool/universe/a/arduino/arduino_1.0.5+dfsg2-4.1_all.deb
dpkg -i arduino_1.0.5+dfsg2-4.1_all.deb
apt-get -f install; rm arduino_1.0.5+dfsg2-4.1_all.deb
wget -O google-earth64.deb http://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb
dpkg -i google-earth64.deb
apt-get -f install; rm google-earth64.deb
passwd local
passwd
cp ./zfs-import-bpool.service /etc/systemd/system/
systemctl enable zfs-import-bpool.service
cp /usr/share/systemd/tmp.mount /etc/systemd/system/
systemctl enable tmp.mount
grub-probe /boot
update-initramfs -u -k all
sed -i '/GRUB_CMDLINE_LINUX=""/s/^/#/g' /etc/default/grub
echo "GRUB_CMDLINE_LINUX="\"root=ZFS=rpool/ROOT/ubuntu"\"\n" >> /etc/default/grub
update-grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi \
      --bootloader-id=ubuntu --recheck --no-floppy
ls /boot/grub/*/zfs.mod
umount /boot/efi
zfs set mountpoint=legacy bpool/BOOT/ubuntu
echo bpool/BOOT/ubuntu /boot zfs \
      nodev,relatime,x-systemd.requires=zfs-import-bpool.service 0 0 >> /etc/fstab
zfs set mountpoint=legacy rpool/var/log
echo rpool/var/log /var/log zfs nodev,relatime 0 0 >> /etc/fstab
zfs set mountpoint=legacy rpool/var/spool
echo rpool/var/spool /var/spool zfs nodev,relatime 0 0 >> /etc/fstab
zfs set mountpoint=legacy rpool/var/tmp
echo rpool/var/tmp /var/tmp zfs nodev,relatime 0 0 >> /etc/fstab
zfs snapshot bpool/BOOT/ubuntu@install
zfs snapshot rpool/ROOT/ubuntu@install
exit
mount | grep -v zfs | tac | awk '/\/mnt/ {print $3}' | xargs -i{} umount -lf {}
zpool export -a
echo Done! Reboot the machine and run final_scripts.sh under /etc/scripts to apply final settings.
