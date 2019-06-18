#!/usr/bin/env bash
# Script created by evansi and hansond @ WWT and Intel on 11/25/2018. Modified by evansi on 6/16/2019

# Generate and set a random hostname
__set_random_hostname() {
  local new_hostname=$(head -n1 < <(fold -w8 < <(tr -cd 'a-z0-9' < /dev/urandom)))
  # set new hostname
  hostnamectl set-hostname "$new_hostname"
  # set new hostname in /etc/hosts
  sed -i "2 s/^.*$/127.0.1.1       $new_hostname/g" /etc/hosts
}

useradd -m -d /home/user/ -s /bin/bash -G sudo user
echo "user:password" | sudo chpasswd

mkdir /root/.cache/dconf
chmod -R 777 /root/.cache/dconf

# Set password for "User" The default password is: password
echo "user:password" | chpasswd

# Run this when having issues on certain apps not running under Wayland.
sudo -u user xhost +si:localuser:root

__set_random_hostname

# Wipe Optane and place L2ARC

installOf="Preparing Optane for ZFS L2ARC. This may take about 3 minutes...  "
printf "$cyan%s\n" "${installOf}"#

zpool remove rpool nvme0n1
dd if=/dev/zero of=/dev/nvme0n1 bs=1M status=progress
zpool add rpool cache nvme0n1
zpool status -v
sleep 5

installStatus="Optane wiped and ZFS L2ARC created!"
printf "$green%s\n" "${installStatus}"

mkdir /etc/deploy
chmod -R 777 /etc/deploy
cp ./packages/gsettings.sh /etc/deploy
cp ./packages/.desktop /etc/xdg/autostart/
cp ./packages/xscreensaver.desktop /etc/xdg/autostart/
chmod +x /etc/deploy/gsettings.sh
cp ./packages/pr_background.jpg /etc/deploy

# Deploy offline packages
#dpkg -i ./packages/*.deb

# Set password for "User" The default password is: password
echo "user:password" | chpasswd

echo off

# Clear bash history one last time
history -c && history -w

# Set keyboard locales
RUID=$(who | awk 'FNR == 1 {print $1}')
RUSER_UID=$(id -u ${RUID})
sudo -Hu ${RUID} DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${RUSER_UID}/bus" gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us+intl')]"

# Organize favorites menu
RUID=$(who | awk 'FNR == 1 {print $1}')
RUSER_UID=$(id -u ${RUID})
sudo -Hu ${RUID} DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${RUSER_UID}/bus" gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'chromium-browser.desktop', 'rhythmbox.desktop', 'vlc.desktop', 'libreoffice-writer.desktop', 'org.gnome.Software.desktop', 'yelp.desktop', 'xfce4-terminal.desktop', 'gnome-control-center.desktop']"

# Change Time to 12HR format and update to Puerto Rico time
RUID=$(who | awk 'FNR == 1 {print $1}')
RUSER_UID=$(id -u ${RUID})
sudo -Hu ${RUID} DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${RUSER_UID}/bus" gsettings set org.gnome.desktop.interface clock-format '12h'
timedatectl set-timezone America/Puerto_Rico

# Install Puerto Rico Dept of Education background
mv /usr/share/backgrounds/warty-final-ubuntu.png /usr/share/backgrounds/warty-final-ubuntu-old.png  
cp ./packages/pr_background.png /usr/share/backgrounds/warty-final-ubuntu.png 
mv /usr/share/xfce4/backdrops/xubuntu-bionic.png /usr/share/xfce4/backdrops/xubuntu-bionic.png.old
cp ./packages/pr_background.png /usr/share/xfce4/backdrops/xubuntu-bionic.png

# Disable Wayland
sed -i '/WaylandEnable/s/^#//g' /etc/gdm3/custom.conf

rm /home/user/Documents
mkdir /home/user/Documents
chmod -R 777 /home/user/Documents
cp ./packages/dwagent.sh /home/user/Documents/
chmod +x /home/user/Documents/dwagent.sh

# Finish some last little tasks...
rm ~/.config/chromium/Default/Bookmarks
rm /etc/alternatives/x-www-browser
ln -s /usr/bin/chromium-browser /etc/alternatives/x-www-browser

# Move logo to designated location for Ubuntu
cp ./packages/logo /usr/share/icons/gothacked.png
# Move desktop file to folder designated for apps
cp ./packages/gothacked.desktop /usr/share/applications
# Symlink file to desktop
ln -s /usr/share/applications/gothacked.desktop ~/Desktop

mkdir /home/user/Desktop/Training
chmod 777 /home/user/Desktop/Training
mkdir /home/user/Desktop/Training/Spanish
mkdir /home/user/Desktop/Training/English
chmod 777 /home/user/Desktop/Training/Spanish
chmod 777 /home/user/Desktop/Training/English

cp ./packages/ENGLISH_training_documentation_and_guide_rev5.pdf /home/user/Desktop/Training/English
cp ./packages/ENGLISH_training_school_presentation_rev5.pptx /home/user/Desktop/Training/English
cp ./packages/SPANISH_training_documentation_and_guide_rev5.pdf /home/user/Desktop/Training/Spanish
cp ./packages/SPANISH_training_school_presentation_rev5.pptx /home/user/Desktop/Training/Spanish

# Create additional user accounts

useradd -m -d /home/Maestro/ -s /bin/bash -G sudo Maestro
echo "Maestro:M@estro" | sudo chpasswd

useradd -m -d /home/Director/ -s /bin/bash -G sudo Director
echo "Director:Intel2018!" | sudo chpasswd

usermod -G user user

sleep 5

# Remove install scripts
rm -Rf /etc/scripts/*

# Final reboot before system is ready to use

reboot

