#!/data/data/com.termux/files/usr/bin/bash

export GREEN='\033[0;32m'
export TURQ='\033[0;36m'
export URED='\033[4;31m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m'
export PROOT_ROOT=$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu_box86/root

echo -e "${GREEN}This script can do the dirty job for you, if you don't want to use the box proot anymore, or there was an error at set up."
echo -e "${URED}"
read -p "Remove the proot-distro ubuntu_box86? (y/n)" yn
echo -e "${WHITE}"

case $yn in 
	y ) echo -e "${GREEN}Remove the proot-distro.${WHITE}"
	    proot-distro remove ubuntu_box86;;
	* ) echo -e "${GREEN}Continue without removing proot-distro.${WHITE}";;
esac

echo -e "${URED}"
read -p "Remove the installed Termux packages? (y/n)" yn
echo -e "${WHITE}"

case $yn in 
	y ) echo -e "${GREEN}Remove the installed Termux packages.${WHITE}"
	    pkg uninstall -y pulseaudio virglrenderer-android xwayland proot-distro wget unzip 
	    pkg uninstall -y x11-repo termux-x11
	    pkg uninstall -y mesa-zink virglrenderer-mesa-zink tur-repo
	    pkg autoclean -y;;
	* ) echo -e "${GREEN}Continue without uninstall.${WHITE}";;
esac

echo -e "${UYELLOW}This will delete everything inside .shortcuts and the Termux .bashrc script, so if you have something custom inside, please skip."
echo -e "${URED}"
read -p "Remove the created .shortcuts and .bashrc? (y/n)" yn
echo -e "${WHITE}"

case $yn in 
	y ) echo -e "${GREEN}Delete .bashrc and .shortcuts.${WHITE}"
	    rm -rf ~/.bashrc
	    rm -rf ~/.shortcuts/*
	* ) echo -e "${GREEN}Continue without deleting.${WHITE}";;
esac

echo -e "${GREEN}Now you are box free!.${WHITE}"
