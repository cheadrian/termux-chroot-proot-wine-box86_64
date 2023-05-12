#!/bin/bash

export GREEN='\033[0;32m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m' 

echo -e "${GREEN}The second stage of the setup that runs inside the Ubuntu proot."
echo -e "${GREEN}This will install XFCE4, Box86, Box64, Wine x86 and x64 and winetricks."
echo -e "${GREEN}It will take a few minutes and about 1GB of space."
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"
echo -e "${GREEN}Install base packages and XFCE4.${WHITE}"

apt update -y && apt upgrade -y
apt install -y dialog apt-utils psmisc htop software-properties-common wget mesa-utils glmark2 dbus-x11 xfce4 xfce4-terminal

echo -e "${GREEN}Adding Box86 and Box64 repo in sources.list.${WHITE}"

wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list
wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
wget https://ryanfortner.github.io/box86-debs/box86.list -O /etc/apt/sources.list.d/box86.list
wget -qO- https://ryanfortner.github.io/box86-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg 

echo -e "${GREEN}Adding ARMHF arch for Box86.${WHITE}"
dpkg --add-architecture armhf

echo -e "${GREEN}Install the Box86 and Box64 packages.${WHITE}"
apt update -y
apt install box64-android libc6:armhf box86-android:armhf -y

echo -e "${GREEN}Install more packages necessary for Box86_64 and Wine86_64.${WHITE}"
apt install -y cabextract libfreetype6 libfreetype6:armhf libfontconfig libfontconfig:armhf libxext6 libxext6:armhf libxinerama-dev libxinerama-dev:armhf libxxf86vm1 libxxf86vm1:armhf libxrender1 libxrender1:armhf libxcomposite1 libxcomposite1:armhf libxrandr2 libxrandr2:armhf libxi6 libxi6:armhf libxcursor1 libxcursor1:armhf libvulkan-dev libvulkan-dev:armhf libgnutls30 libgnutls30:armhf

echo -e "${GREEN}Download Wine 8.7 x86 and x64 from Wine-Builds.${WHITE}"
wget https://github.com/Kron4ek/Wine-Builds/releases/download/8.7/wine-8.7-x86.tar.xz
wget https://github.com/Kron4ek/Wine-Builds/releases/download/8.7/wine-8.7-amd64.tar.xz

echo -e "${GREEN}Unpack Wine 8.7 x86 to ~/wine and x86 to ~/wine64.${WHITE}"
tar xvf wine-8.7-x86.tar.xz
tar xvf wine-8.7-amd64.tar.xz
rm wine-8.7-x86.tar.xz wine-8.7-amd64.tar.xz
mv wine-8.7-x86 wine
mv wine-8.7-amd64 wine64
	
echo -e "${GREEN}Add necessary BOX paths inside .bashrc.${WHITE}"
echo 'export DISPLAY=:0
PULSE_SERVER=tcp:127.0.0.1:4713
export BOX86_PATH=~/wine/bin/
export BOX86_LD_LIBRARY_PATH=~/wine/lib/wine/i386-unix/:/lib/i386-linux-gnu/:/lib/aarch64-linux-gnu/:/lib/arm-linux-gnueabihf/:/usr/lib/aarch64-linux-gnu/:/usr/lib/arm-linux-gnueabihf/:/usr/lib/i386-linux-gnu/
export BOX64_PATH=~/wine64/bin/
export BOX64_LD_LIBRARY_PATH=~/wine64/lib/i386-unix/:~/wine64/lib/wine/x86_64-unix/:/lib/i386-linux-gnu/:/lib/x86_64-linux-gnu:/lib/aarch64-linux-gnu/:/lib/arm-linux-gnueabihf/:/usr/lib/aarch64-linux-gnu/:/usr/lib/arm-linux-gnueabihf/:/usr/lib/i386-linux-gnu/:/usr/lib/x86_64-linux-gnu' >> ~/.bashrc
source ~/.bashrc

echo -e "${GREEN}Create shortcuts for the wine with box."
echo -e "${UYELLOW}You can use Wine x86 using the 'wine' command and Wine x64 using the 'wine64'.${WHITE}"
echo '#!/bin/bash 
export WINEPREFIX=~/.wine32
box86 '"$HOME/wine/bin/wine "'"$@"' > /usr/local/bin/wine
chmod +x /usr/local/bin/wine
echo '#!/bin/bash 
export WINEPREFIX=~/.wine64
box64 '"$HOME/wine64/bin/wine64 "'"$@"' > /usr/local/bin/wine64
chmod +x /usr/local/bin/wine64

echo -e "${GREEN}Create wine prefix for x86 and x64 version to ~/.wine32 and ~/.wine64.${WHITE}"
wine wineboot
wine64 wineboot


echo -e "${GREEN}Install winetricks.${WHITE}"
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
mv winetricks /usr/local/bin/
	
echo -e "${GREEN}Create shortcuts for the winetricks.${WHITE}"
echo -e "${UYELLOW}You can use Winetricks for Wine x86 using the 'winetricks32' command and Winetricks for Wine x64 using the 'winetricks64'.${WHITE}"
echo '#!/bin/bash 
export BOX86_NOBANNER=1 WINE=wine WINEPREFIX=~/.wine32 WINESERVER=~/wine/bin/wineserver
wine '"/usr/local/bin/winetricks "'"$@"' > /usr/local/bin/winetricks32
chmod +x /usr/local/bin/winetricks32
echo '#!/bin/bash 
export BOX64_NOBANNER=1 WINE=wine64 WINEPREFIX=~/.wine64 WINESERVER=~/wine64/bin/wineserver
wine64 '"/usr/local/bin/winetricks "'"$@"' > /usr/local/bin/winetricks64
chmod +x /usr/local/bin/winetricks64


echo -e "${GREEN}Add desktop shortcuts for wine.{WHITE}"
mkdir ~/Desktop
cd ~/Desktop
echo '[Desktop Entry]
Name=Wine32 Explorer
Exec=bash -c "wine explorer"
Icon=wine
Type=Application' > ~/Desktop/Wine32_Explorer.desktop
chmod +x ~/Desktop/Wine32_Explorer.desktop
cp ~/Desktop/Wine32_Explorer.desktop /usr/share/applications/

echo '[Desktop Entry]
Name=Wine64 Explorer
Exec=bash -c "wine64 explorer"
Icon=wine
Type=Application' > ~/Desktop/Wine64_Explorer.desktop
chmod +x ~/Desktop/Wine64_Explorer.desktop
cp ~/Desktop/Wine64_Explorer.desktop /usr/share/applications/
	
echo -e "${GREEN}Add desktop shortcuts for winetricks.${WHITE}":
echo '[Desktop Entry]
Name=Winetricks32 Explorer
Exec=bash -c "winetricks32 --gui"
Icon=wine
Type=Application' > ~/Desktop/Winetricks32_gui.desktop
chmod +x ~/Desktop/Winetricks32_gui.desktop
cp ~/Desktop/Winetricks32_gui.desktop /usr/share/applications/

echo '[Desktop Entry]
Name=Winetricks64 Explorer
Exec=bash -c "winetricks64 --gui"
Icon=wine
Type=Application' > ~/Desktop/Winetricks64_gui.desktop
chmod +x ~/Desktop/Winetricks64_gui.desktop
cp ~/Desktop/Winetricks64_gui.desktop /usr/share/applications/

echo -e "${UYELLOW}You need zenity to run winetricks --gui desktop shortcuts, which is space consuming.${WHITE}"

read -p "Do you want to install zenity? (y/n) " yn

case $yn in 
	y ) echo -e "${GREEN}Install zenity...";
		apt install -y zenity;;
	* ) echo -e "${GREEN}You can install zenity with apt anytime.${WHITE}";;
esac

echo -e "${GREEN}Add desktop shortcuts for glmark2 software and virpipe.${WHITE}"
echo '[Desktop Entry]
Name=GL2Mark software
Exec=bash -c "env MESA_GL_VERSION_OVERRIDE=4.5COMPAT glmark2"
Icon=gl2mark
Terminal=true
Type=Application' > ~/Desktop/GL2Mark_llvmpipe.desktop
chmod +x ~/Desktop/GL2Mark_llvmpipe.desktop

echo '[Desktop Entry]
Name=GL2Mark virpipe
Exec=bash -c "env MESA_GL_VERSION_OVERRIDE=4.5COMPAT GALLIUM_DRIVER=virpipe glmark2"
Icon=gl2mark
Terminal=true
Type=Application' > ~/Desktop/GL2Mark_virpipe.desktop
chmod +x ~/Desktop/GL2Mark_virpipe.desktop

echo -e "${GREEN}Great, proot setup is completed! \nGoing back to the first stage to create the shortcuts and start-up scripts.${WHITE}"
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"