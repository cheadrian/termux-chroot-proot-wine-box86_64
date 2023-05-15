#!/bin/bash -i

export GREEN='\033[0;32m'
export URED='\033[4;31m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m' 

echo -e "${GREEN}PlayOnLinux works fine within the 'box' user with the script '/usr/local/bin/wine' created at set up."
echo -e "${UYELLOW}Due to lack of binfmt, you need to set BEFORE_WINE=box86 or box64 to use different version of wine, other than system, through Box86_64.${WHITE}"
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"

echo -e "${GREEN}Run the scripts that add 'box' user and configure Box Bash.${WHITE}"
./Addons_Proot_Add_user.sh
./Addons_Proot_Box86_64_Bash.sh

echo -e "${GREEN}Install playonlinux.${WHITE}"
apt install -y playonlinux

echo -e "${GREEN}Add desktop shortcuts for PoL run as 'box'.${WHITE}":
echo '[Desktop Entry]
Version=1.0
Name=PlayOnLinux Box
Comment=Front-end application for the wine
Type=Application
Exec=sudo -E -H -u box BEFORE_WINE=box86 playonlinux %F
Icon=playonlinux
Categories=Utility;Emulator;' > ~/Desktop/PlayOnLinux_box.desktop
chmod +x ~/Desktop/PlayOnLinux_box.desktop
cp ~/Desktop/PlayOnLinux_box.desktop /usr/share/applications/

echo -e "${GREEN}Add desktop shortcuts for PoL run as 'box'.${WHITE}":
echo '[Desktop Entry]
Version=1.0
Name=PlayOnLinux Box64
Comment=Front-end application for the wine
Type=Application
Exec=sudo -E -H -u box BEFORE_WINE=box64 box64 playonlinux %F
Icon=playonlinux
Categories=Utility;Emulator;' > ~/Desktop/PlayOnLinux_box64.desktop
chmod +x ~/Desktop/PlayOnLinux_box64.desktop
cp ~/Desktop/PlayOnLinux_box64.desktop /usr/share/applications/

echo -e "${UYELLOW}Next time you can run PlayOnLinux, from 'root' user, using the desktop shortcuts or: 'sudo -E -H -u box BEFORE_WINE=box86 playonlinux' or copy the relevant env variables (.bashrc) to the 'box' user.${WHITE}"
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"