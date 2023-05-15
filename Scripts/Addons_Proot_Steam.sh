#!/bin/bash -i

export GREEN='\033[0;32m'
export URED='\033[4;31m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m' 

echo -e "${GREEN}This script will help you install Steam using Box86 'install_steam.sh' and Box86 bash, inside 'box' user."
echo -e "${UYELLOW}Run this in a proot without '--no-sysvipc' otherwise Steam will throw 'semaphore' errors.\nSadly, some devices can't run all proot functions without '--no-sysvipc'.\nCheck: https://github.com/ptitSeb/box86/issues/699 and https://box86.org/2022/09/running-bash-with-box86-box64/"
echo -e "${URED}W.I.P.: For now (12 May 2023) it throws 'Fatal error: futex robust_list not initialized by pthreads' error.\nCheck: https://github.com/ptitSeb/box86/issues/770 ${WHITE}"
echo -e "${UYELLOW}Make sure you have the XFCE and Termux:X11 is already running.${WHITE}"
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"

echo -e "${GREEN}Run the scripts that add 'box' user and configure Box Bash.${WHITE}"
./Addons_Proot_Add_user.sh
./Addons_Proot_Box86_64_Bash.sh

echo -e "${GREEN}Add some necesary Steam packages.${WHITE}"
apt install -y binutils xterm file zenity pciutils libcairo2 libcairo2:armhf libxdamage1 libxdamage1:armhf libjpeg-dev libjpeg-dev:armhf libselinux1 libselinux1:armhf libgl1-mesa-glx libgl1-mesa-glx:armhf libogg-dev libogg-dev:armhf libvorbis-dev libvorbis-dev:armhf libice6 libice6:armhf libxss1 libxss1:armhf libxtst6 libxtst6:armhf libbz2-dev libbz2-dev:armhf libsm6 libsm6:armhf

echo -e "${GREEN}Install libpng12.${WHITE}"
mkdir ~/Downloads/libpng
cd ~/Downloads/libpng
wget http://launchpadlibrarian.net/377987065/libpng12-0_1.2.54-1ubuntu1.1_armhf.deb
wget http://launchpadlibrarian.net/377986999/libpng12-0_1.2.54-1ubuntu1.1_arm64.deb
dpkg -i *.deb
cd ~
rm -r ~/Downloads/libpng

echo -e "${GREEN}Install steam using the Box86 script, in 'box' user.${WHITE}"

sudo -H -i -u box bash << EOF
wget https://raw.githubusercontent.com/ptitSeb/box86/master/install_steam.sh
chmod +x install_steam.sh
./install_steam.sh
EOF

source ~/.bashrc
echo -e "${GREEN}Run Steam through bash86, using 'box' user.${WHITE}"
sudo -E -H -u box box86 steam

echo -e "${UYELLOW}Next time you can run Steam, from 'root' user, using: 'sudo -E -H -u box box86 steam' or copy the relevant env variables (.bashrc) to the 'box' user.${WHITE}"
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"