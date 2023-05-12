#!/data/data/com.termux/files/usr/bin/bash

export GREEN='\033[0;32m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m' 

echo -e "${GREEN}Clone the repo."
apt install -y git
cd ~
git clone https://github.com/cheadrian/termux-chroot-proot-wine-box86_64
cd termux-chroot-proot-wine-box86_64/Scripts

echo -e "${GREEN}Run the install script."
sleep 1
chmod +x *.sh
./Stage_1_Install_Proot_VirGL_Box86_Wine.sh
