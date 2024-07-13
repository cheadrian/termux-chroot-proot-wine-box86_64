#!/bin/bash
export GREEN='\033[0;32m'
export URED='\033[4;31m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m' 

echo -e "${GREEN}The second stage of the setup that runs inside the Ubuntu proot."
echo -e "${GREEN}This will install XFCE4, Box86, Box64, Wine x86 and x64 and winetricks."
echo -e "${GREEN}It will take a few minutes and about 3.5 GB of space.${WHITE}"
echo -e "Press any key to continue.\n"
read -n 1 -s -r

# Updates the package list, upgrades existing packages, and installs various base packages
# and XFCE4 desktop environment with terminal, utilities, and graphics components.
update_install_base_packages(){
	set -e
	echo -e "${GREEN}Install base packages and XFCE4.${WHITE}"
	apt update -y && apt upgrade -y
	apt install -y dialog apt-utils psmisc htop software-properties-common wget mesa-utils glmark2 dbus-x11 xfce4 xfce4-terminal
}

# Adds two repositories, Box86 and Box64, to the system's package sources list,
# then downloads and installs the Box86 and Box64 packages, including necessary dependencies,
# enabling ARMHF architecture support for Box86.
install_box86_box64_from_repo(){
	set -e
	echo -e "${GREEN}Adding Box86 and Box64 repo in sources.list.${WHITE}"
	wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list
	wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
	wget https://ryanfortner.github.io/box86-debs/box86.list -O /etc/apt/sources.list.d/box86.list
	wget -qO- https://ryanfortner.github.io/box86-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg 
	echo -e "${GREEN}Adding ARMHF arch for Box86.${WHITE}"
	dpkg --add-architecture armhf
	echo -e "${GREEN}Install the Box86 and Box64 packages.${WHITE}"
	apt update -y
	apt install box64-android libc6 libc6:armhf box86-android:armhf -y
}

# Installs a list of packages necessary for Box86_64 and Wine86_64, 
# along with their corresponding ARMHF architecture versions. 
# These packages include various libraries and dependencies required for 
# running applications and games with Box86 and Box64 on an ARM-based system.
install_packages_for_box86_box64(){
	set -e
	echo -e "${GREEN}Install more packages necessary for Box86_64 and Wine86_64.${WHITE}"
	apt install -y cabextract libfreetype6 libfreetype6:armhf libfontconfig libfontconfig:armhf libxext6 libxext6:armhf libxinerama-dev libxinerama-dev:armhf libxxf86vm1 libxxf86vm1:armhf libxrender1 libxrender1:armhf libxcomposite1 libxcomposite1:armhf libxrandr2 libxrandr2:armhf libxi6 libxi6:armhf libxcursor1 libxcursor1:armhf libvulkan-dev libvulkan-dev:armhf libgnutls30 libgnutls30:armhf libasound2:armhf libglib2.0-0:armhf libgphoto2-6:armhf libgphoto2-port12:armhf libgstreamer-plugins-base1.0-0:armhf libgstreamer1.0-0:armhf libldap-common libldap-common:armhf libopenal1 libopenal1:armhf libpcap0.8:armhf libpulse0 libpulse0:armhf libsane1:armhf libudev1:armhf libusb-1.0-0:armhf libvkd3d1:armhf libx11-6:armhf libasound2-plugins:armhf ocl-icd-libopencl1:armhf libncurses6:armhf libcap2-bin:armhf libcups2:armhf libdbus-1-3:armhf libfontconfig1:armhf libglu1-mesa:armhf libglu1:armhf libgssapi-krb5-2:armhf libkrb5-3:armhf libodbc2 libodbc2:armhf libosmesa6:armhf libsdl2-2.0-0:armhf libv4l-0:armhf libxfixes3:armhf libxinerama1:armhf
}

# This bash function downloads Wine for x86 and x64 architectures from the Wine-Builds repository,
# then unpacks the downloaded archives and moves the contents 
# to separate directories named "wine" for x86 and "wine64" for x64.
# Default version: 9.7.
install_wine86_wine64(){
	set -e
	known_versions=("9.8" "9.0" "8.13" "8.7" "7.22" "6.23" "5.22")
	echo -e "${GREEN}Possible Wine versions: ${known_versions[@]}${WHITE}"
	echo -e "${UYELLOW}Check Kron4ek/Wine-Builds for released versions.${WHITE}"
	echo -e "${UYELLOW}Enter the Wine version you want to install, (default 9.8):${WHITE}"
	version_regex="^[0-9]+\.[0-9]{2}$"
	read version
	if ! [[ $version =~ $version_regex ]]; then
		echo -e "${UYELLOW}Invalid version format. Defaulting to 9.8.${WHITE}"
		version="9.8"
	fi
	echo -e "${GREEN}Downloading Wine $version x86 and x64 from Wine-Builds.${WHITE}"
	wget "https://github.com/Kron4ek/Wine-Builds/releases/download/$version/wine-$version-x86.tar.xz"
	wget "https://github.com/Kron4ek/Wine-Builds/releases/download/$version/wine-$version-amd64.tar.xz"
	echo -e "${GREEN}Unpacking Wine $version x86 to ~/wine and x86 to ~/wine64.${WHITE}"
	tar xvf "wine-$version-x86.tar.xz"
	tar xvf "wine-$version-amd64.tar.xz"
	rm "wine-$version-x86.tar.xz" "wine-$version-amd64.tar.xz"
	mv "wine-$version-x86" wine
	mv "wine-$version-amd64" wine64
}

# Adds necessary paths for Box86 and Box64 to the user's .bashrc file. 
# It sets environment variables for DISPLAY and PULSE_SERVER,
# defines paths for Box86 (BOX86_PATH and BOX86_LD_LIBRARY_PATH),
# and Box64 (BOX64_PATH and BOX64_LD_LIBRARY_PATH), 
# pointing to various directories where libraries and executables for Box86 and Box64 are located.
add_box_to_path(){
	set -e
	echo -e "${GREEN}Add necessary BOX paths inside .bashrc.${WHITE}"
	echo 'export DISPLAY=:0
PULSE_SERVER=tcp:127.0.0.1:4713
export BOX86_PATH=~/wine/bin/
export BOX86_LD_LIBRARY_PATH=~/wine/lib/wine/i386-unix/:/lib/i386-linux-gnu/:/lib/aarch64-linux-gnu/:/lib/arm-linux-gnueabihf/:/usr/lib/aarch64-linux-gnu/:/usr/lib/arm-linux-gnueabihf/:/usr/lib/i386-linux-gnu/
export BOX64_PATH=~/wine64/bin/
export BOX64_LD_LIBRARY_PATH=~/wine64/lib/i386-unix/:~/wine64/lib/wine/x86_64-unix/:/lib/i386-linux-gnu/:/lib/x86_64-linux-gnu:/lib/aarch64-linux-gnu/:/lib/arm-linux-gnueabihf/:/usr/lib/aarch64-linux-gnu/:/usr/lib/arm-linux-gnueabihf/:/usr/lib/i386-linux-gnu/:/usr/lib/x86_64-linux-gnu' >> ~/.bashrc
	source ~/.bashrc
}

# Creates two shortcuts for running Wine with Box86 and Box64.
create_terminal_shortcuts_box(){
	set -e
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
}

# Creates two shortcuts for running Proton with Box86 and Box64 (coming soon™).
create_terminal_shortcuts_proton_box(){
	set -e
	echo -e "${GREEN}Create shortcuts for Proton with box."
	echo -e "${UYELLOW}You can use Proton x86 using the 'proton' command and Proton x64 using the 'proton64'.${WHITE}"
	echo '#!/bin/bash 
export WINEPREFIX=~/.proton32
box86 '"$HOME/proton/bin/wine "'"$@"' > /usr/local/bin/proton
	chmod +x /usr/local/bin/proton
	echo '#!/bin/bash 
export WINEPREFIX=~/.wine64
box64 '"$HOME/proton64/bin/wine64 "'"$@"' > /usr/local/bin/proton64
	chmod +x /usr/local/bin/proton64
}

# Creates two Wine prefixes for Wine x86 and Wine x64 versions in the user's home directory.
create_wine86_wine64_prefix(){
	set -e
	echo -e "${GREEN}Create wine prefix for x86 and x64 version to ~/.wine32 and ~/.wine64.${WHITE}"
	wine wineboot
	wine64 wineboot
}

# This bash function installs winetricks by downloading the script from GitHub and making it executable in /usr/local/bin/.
install_winetricks(){
	set -e
	echo -e "${GREEN}Install winetricks.${WHITE}"
	wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
	chmod +x winetricks
	mv winetricks /usr/local/bin/
}

# This bash function creates two shortcuts for using Winetricks with Wine x86 and Wine x64. 
# The 'winetricks32' and 'winetricks64' commands set specific environment variables 
# and execute Winetricks with the appropriate Wine versions.
create_terminal_shortcuts_winetricks(){
	set -e
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
}

# This bash function creates desktop shortcuts for Wine x86 and x64 explorers, 
# Winetricks with Wine x86 and x64 in GUI mode, and GL2Mark software with Virpipe driver.
create_desktop_shortcuts(){
	set -e
	echo -e "${GREEN}Add desktop shortcuts for wine.${WHITE}"
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
}

# This bash function checks if Zenity is installed, and if not, it prompts the user to install it. 
# Zenity is needed to run Winetricks in GUI mode for desktop shortcuts.
install_zenity(){
	echo -e "${UYELLOW}You need zenity to run winetricks --gui desktop shortcuts, which is space consuming.${WHITE}"
	echo -e "Do you want to install zenity? (y/n) "
	read yn
	case $yn in 
		y ) echo -e "${GREEN}Install zenity...${WHITE}";
			apt install -y zenity;;
		* ) echo -e "${GREEN}You can install zenity with apt anytime.${WHITE}";;
	esac
}

# Function to run a function, perform exit status check, and pause with read timeout.
function rftc() {
	local func_name=$1
	local timeout=$2
	echo -e "${GREEN}Running step: ${func_name} - stage 2.${WHITE}"
	($func_name)
	# Check if every command inside the function is executed successfully.
	if [ $? -eq 0 ]; then
		echo -e "${GREEN}${func_name} - stage 2 - completed successfully.${WHITE}"
		echo -e "${GREEN}Pausing for ${timeout} seconds...${WHITE}"
		echo -e "\n"
		sleep $timeout
	else
		echo -e "${URED}${func_name} - stage 2 - encountered an error.${WHITE}"
		exit 2
	fi
}

# Run everything in sequencial order
rftc update_install_base_packages 2
rftc install_box86_box64_from_repo 2
rftc install_packages_for_box86_box64 2
rftc install_wine86_wine64 2
rftc add_box_to_path 2
rftc create_terminal_shortcuts_box 2
rftc create_wine86_wine64_prefix 2
rftc install_winetricks 2
rftc create_terminal_shortcuts_winetricks 2
rftc create_desktop_shortcuts 2
rftc install_zenity 2

echo -e "${GREEN}Great, proot setup is completed! \nGoing back to the first stage to create the shortcuts and start-up scripts.${WHITE}"
echo -e "Waiting 5 seconds to continue..."
sleep 5
