#!/data/data/com.termux/files/usr/bin/bash
export GREEN='\033[0;32m'
export URED='\033[4;31m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m'

# Note: if you update the artifact link, please check the zip has the same structure.
# Otherwise you need to update the 'install_termux_x11_pkg_app' function.
export X11_APK_LINK='https://github.com/termux/termux-x11/releases/download/nightly/app-universal-debug.apk'
export X11_COMPANION_LINK='https://github.com/termux/termux-x11/releases/download/nightly/termux-x11-nightly-1.03.00-0-all.deb'
export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo -e "${UYELLOW}If you are on Android 12+, make sure to fix Phantom Processes Kill. Check Setup_Proot.md for more details."
echo -e "${GREEN}This script will install Termux:X11, virgl server for GPU acceleration, and inside an Ubuntu proot, Box86, Wine.${WHITE}"
echo -e "${UYELLOW}If anything fails (due to lack of network or other reason), you can run the remove script using './Scripts/Addons_Menu.sh' and try again.${WHITE}"
echo -e "Press any key to continue. \n"
read -n 1 -s -r

# Verify if the script was run before and let user to remove everything
check_if_is_installed(){
	if  [ -e "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu_box86" ] || \
		[ -e "~/.shortcuts/KillXFCE_proot" ] || \
		[ -e "~/.shortcuts/LaunchXFCE_proot" ]; then
			echo -e "${UYELLOW}Looks like there was an attempt to install this.${WHITE}"
			echo -e "${GREEN}Recommended: remove everything and start again.${WHITE}"
			echo -e "${UYELLOW}Do you want to remove everything? (y/n)${WHITE}"
			read yn
			case $yn in
				y ) echo -e "${UYELLOW}Running removal script.${WHITE}"
					chmod +x $SCRIPT_DIR/Remove_Everything.sh
					$SCRIPT_DIR/Remove_Everything.sh
					echo -e "${GREEN}Now you can run the script again.${WHITE}"
					;;
				*)
					echo -e "${UYELLOW}Continue to install. Note: script might fail if proot is already set up.${WHITE}"
					;;
			esac
	fi
}

# Function to create a shortcut to the addons menu.
create_addons_menu_alias(){
	echo -e "${GREEN}Add 'Addons_Menu.sh' alias.${WHITE}"
	if ! grep -q "addons_menu" ~/.bashrc; then
		echo 'alias addons_menu="~/termux-chroot-proot-wine-box86_64/Scripts/Addons_Menu.sh"
echo -e "addons_menu - Open the addons menu for box"' >> ~/.bashrc
	fi
	echo -e "${UYELLOW}Run 'source ~/.bashrc' to use 'addons_menu' command, or reopen Termux.${WHITE}"
	echo -e "${UYELLOW}You can use this menu only to remove everything till installation is finished.${WHITE}"
}

# Function to update and install essential base packages, including x11-repo and optional SSH setup.
update_install_base_packages(){
	set -e
	echo -e "${GREEN}Update and upgrade packages.${WHITE}"
	pkg update -y && pkg upgrade -y
	echo -e "${GREEN}Add x11-repo.${WHITE}"
	pkg install -y x11-repo 
	pkg update -y
	echo -e "${GREEN}Install virgl, pulseaudio, xwayland, proot, wget.${WHITE}"
	pkg install -y pulseaudio virglrenderer-android xwayland proot-distro wget unzip 
	echo -e "${UYELLOW} Optional: Do you want to setup a ssh server (openssh)? (y/n)${WHITE}"
	read yn
	case $yn in 
		y ) echo -e "${GREEN}Install openssh...${WHITE}"
			apt install -y openssh
			echo -e "${UYELLOW}To connect through ssh, use password you set next and port 8022.${WHITE}"
			passwd;;
		* ) echo -e "${GREEN}Continue without installing ssh.${WHITE}";;
	esac
}

# Function to install Termux:X11 companion and APK.
# This function facilitates the installation of Termux:X11 companion and APK.
install_termux_x11_pkg_app(){
	set -e	
	echo -e "${GREEN}Install Termux:X11 companion and apk."
	echo -e "${UYELLOW}Note: you can get the latest version from termux/termux-x11 Github.${WHITE}"
	# For the moment, use version from artifact to make sure it is compatible with app
	# pkg install -y termux-x11-nightly
	wget $X11_APK_LINK -O Termux-X11-app-universal-debug.apk
	wget $X11_COMPANION_LINK -O termux-x11-nightly-all.deb
	dpkg -i termux-x11-nightly-all.deb
	sed '/allow-external-apps/s/^# //' -i ~/.termux/termux.properties
	termux-reload-settings
	echo -e "${GREEN}Install Termux:X11 APK. Open APP installer.${WHITE}"
	termux-open Termux-X11-app-universal-debug.apk
}

# Function to create a proot environment for Ubuntu and install necessary components.
setup_ubuntu_proot(){
	set -e
	echo -e "${GREEN}Create an Ubuntu proot."
	echo -e "${UYELLOW}Note: the proot alias is ubuntu_box86."
	echo -e "${GREEN}Path: \$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu_box86/${WHITE}"
	proot-distro install ubuntu --override-alias ubuntu_box86
	echo -e "${GREEN}Put the second stage script inside the proot.${WHITE}"
	cp Stage_2_Install_Proot_VirGL_Box86_Wine.sh $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu_box86/root/Stage_2_Install_Proot_VirGL_Box86_Wine.sh
	chmod +x $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu_box86/root/Stage_2_Install_Proot_VirGL_Box86_Wine.sh
	proot-distro login ubuntu_box86 --user root --shared-tmp --no-sysvipc -- bash -c "./Stage_2_Install_Proot_VirGL_Box86_Wine.sh"
	rm $PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu_box86/root/Stage_2_Install_Proot_VirGL_Box86_Wine.sh
}

# Function to install Termux:Widget app, enabling compatible shortcuts. 
# User prompted to setup optional Termux:API for toast messages. 
# Downloads and opens apk for installation.
install_termux_widget_app(){
	set -e
	echo -e "${GREEN}Create shortcuts compatible with Termux:Widget."
	echo -e "${UYELLOW}Download and install Termux:Widget from Github and add the shortcut list widget on the launcher."
	echo -e "${UYELLOW}Optional: for toast message at start, set up the Termux:API.${WHITE}"
	wget https://github.com/termux/termux-widget/releases/download/v0.13.0/termux-widget_v0.13.0+github-debug.apk
	termux-open termux-widget_v0.13.0+github-debug.apk
}

# Function to create shortcuts for launching and killing Termux:X11, pulseaudio, virgl server, and XFCE using proot.
# It creates two scripts, 'LaunchXFCE_proot' and 'KillXFCE_proot,' in the ~/.shortcuts.
create_shortcuts_for_widget(){
	set -e
	echo -e "${GREEN}Add shortcuts to launch Termux:X11 app, pulseaudio, virgl server, and XFCE in proot.${WHITE}"
	mkdir -p ~/.shortcuts
	echo '#!/bin/sh
killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android virgl_test_server
termux-wake-lock; termux-toast "Starting X11"
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity
XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :0 -ac & 
sleep 3
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
virgl_test_server_android &
proot-distro login ubuntu_box86 --user root --shared-tmp --no-sysvipc -- bash -c "export DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1:4713; dbus-launch --exit-with-session startxfce4"' > ~/.shortcuts/LaunchXFCE_proot
	chmod +x ~/.shortcuts/LaunchXFCE_proot
	echo -e "${GREEN}Create a kill all shortcut.${WHITE}"
	echo '#!/bin/sh
killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android virgl_test_server 
termux-wake-unlock; termux-toast "Stopping X11, virgl, etc."' > ~/.shortcuts/KillXFCE_proot
	chmod +x ~/.shortcuts/KillXFCE_proot
}

# This function creates two aliases, 'start_box_proot' and 'kill_box_proot'. 
# Allow users to use the shortcuts conveniently inside Termux.
add_bash_alias_for_shortcuts(){
	set -e
	echo -e "${GREEN}Create an alias to make shortcuts usable inside Termux."
	echo -e "${UYELLOW}Now can use 'start_box_proot' and 'kill_box_proot' in terminal, or by using Termux:Widget on the launcher.${WHITE}"
	if ! grep -q "start_box_proot" ~/.bashrc; then
		echo 'alias start_box_proot="sh ~/.shortcuts/LaunchXFCE_proot"
alias kill_box_proot="sh ~/.shortcuts/KillXFCE_proot"
echo -e "start_box_proot - Launch the proot XFCE, Termux:X11\nkill_box_proot - Kill virgl server, pulseaudio, etc."' >> ~/.bashrc
	fi
	echo -e "${UYELLOW}Do not forget to 'source ~/.bashrc' after script finish.${WHITE}"
}

# This will cleanup files that are not needed anymore.
cleanup(){
	echo -e "${GREEN}Clean downloaded resources (Termux_X11, Termux_widget, etc.).${WHITE}"
	rm -r Termux_X11
	rm -r Termux_X11_companion
	rm termux-x11-nightly-all.deb
	rm termux-widget*.apk
	rm Termux-X11*.apk
}

# Function to run a function, perform exit status check, and pause with read timeout.
function rftc() {
	local func_name=$1
	local timeout=$2
	echo -e "${GREEN}Running step: ${func_name}.${WHITE}"
	($func_name)
	# Check if every command inside the function is executed successfully.
	if [ $? -eq 0 ]; then
		echo -e "${GREEN}${func_name} completed successfully.${WHITE}"
		echo -e "${GREEN}Pausing for ${timeout} seconds...${WHITE}"
		echo -e "\n"
		sleep $timeout
	else
		echo -e "${URED}${func_name} encountered an error.${WHITE}"
		echo -e "${UYELLOW}Please use the 'cd termux-chroot-proot-wine-box86_64', './Scripts/Addons_Menu.sh' and select remove script or delete Termux App data and try again.${WHITE}"
		echo -e "Error can be from network, incompatibility, outdated 'X11_APK_LINK', 'X11_COMPANION_LINK' or script problem due Termux / Android updates."
		exit 2
	fi
}

# Run everything in sequencial order
rftc check_if_is_installed 1
rftc create_addons_menu_alias 4
rftc update_install_base_packages 2
rftc install_termux_x11_pkg_app 10
rftc setup_ubuntu_proot 2
rftc install_termux_widget_app 2
rftc create_shortcuts_for_widget 2
rftc add_bash_alias_for_shortcuts 2
rftc cleanup 1

echo -e "${GREEN}Enjoy. Check out the markdown files in the git for more details.${WHITE}"
echo -e "${UYELLOW}Don't forget to run 'source ~/.bashrc'!${WHITE}"
echo -e "${UYELLOW}You can install some addons, Box Bash, Steam, Zink, etc. using 'addons_menu' command.${WHITE}"