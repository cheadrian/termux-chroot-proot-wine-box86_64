#!/data/data/com.termux/files/usr/bin/bash

export GREEN='\033[0;32m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m' 

pkg update -y
read -p "Do you want to change the Termux repo to a faster one? (y/n) " yn

case $yn in 
	y ) termux-change-repo;;
	* ) echo -e "${GREEN}Continue with the current repo.${WHITE}";;
esac

echo -e "${GREEN}Clone the repo.${WHITE}"
pkg install -y git
cd ~
git clone https://github.com/cheadrian/termux-chroot-proot-wine-box86_64
cd termux-chroot-proot-wine-box86_64/Scripts

echo -e "${GREEN}Run the install script.${WHITE}"
sleep 1
chmod +x *.sh
./Stage_1_Install_Proot_VirGL_Box86_Wine.sh
