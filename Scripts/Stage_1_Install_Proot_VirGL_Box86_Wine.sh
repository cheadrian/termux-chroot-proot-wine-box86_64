#!/data/data/com.termux/files/usr/bin/bash
set -e
export GREEN='\033[0;32m'
export URED='\033[4;31m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m'

# Note: if you update the artifact link, please check the zip has the same structure.
# Otherwise you need to update the 'install_termux_x11_pkg_app' function.
export X11_ARTIFACT_LINK='https://nightly.link/termux/termux-x11/actions/artifacts/800168706.zip'

echo -e "${UYELLOW}If you are on Android 12+, make sure to fix Phantom Processes Kill. Check Setup_Proot.md for more details."
echo -e "${GREEN}This script will install Termux:X11, virgl server for GPU acceleration, and inside an Ubuntu proot, Box86, Wine.${WHITE}"
echo -e "${UYELLOW}If anything fails (due to lack of network or other reason), you can run the remove script using './Scripts/Addons_Menu.sh' and try again.${WHITE}"
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"


# Function to update and install essential base packages, including x11-repo and optional SSH setup.
update_install_base_packages(){
	echo -e "${GREEN}Update and upgrade packages.${WHITE}"
	pkg update -y && pkg upgrade -y
	
	echo -e "${GREEN}Add x11-repo.${WHITE}"
	pkg install -y x11-repo 
	pkg update -y
	
	echo -e "${GREEN}Install virgl, pulseaudio, xwayland, proot, wget.${WHITE}"
	pkg install -y pulseaudio virglrenderer-android xwayland proot-distro wget unzip 
	
	read -p "Optional: Do you want to setup a ssh server (openssh)? (y/n) " yn
	
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
	echo -e "${GREEN}Install Termux:X11 companion and apk."
	echo -e "${UYELLOW}Note: you can get the latest version from termux/termux-x11 Github.${WHITE}"
	pkg install -y termux-x11-nightly
	wget $X11_ARTIFACT_LINK -O Termux_X11.zip
	unzip Termux_X11.zip -d Termux_X11
	rm Termux_X11.zip
	sed '/allow-external-apps/s/^# //' -i ~/.termux/termux.properties
	termux-reload-settings
	echo -e "${GREEN}Install Termux:X11 APK. Open APP installer.${WHITE}"
	termux-open Termux_X11/app-universal-debug.apk
}

# Function to create a proot environment for Ubuntu and install necessary components.
setup_ubuntu_proot(){
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
	echo -e "${GREEN}Create shortcuts compatible with Termux:Widget."
	echo -e "${UYELLOW}Download and install Termux:Widget from Github and add the shortcut list widget on the launcher."
	echo -e "${UYELLOW}Optional: for toast message at start, set up the Termux:API.${WHITE}"
	wget https://github.com/termux/termux-widget/releases/download/v0.13.0/termux-widget_v0.13.0+github-debug.apk
	termux-open termux-widget_v0.13.0+github-debug.apk
}

# Function to create shortcuts for launching and killing Termux:X11, pulseaudio, virgl server, and XFCE using proot.
# It creates two scripts, 'LaunchXFCE_proot' and 'KillXFCE_proot,' in the ~/.shortcuts.
create_shortcuts_for_widget(){
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
	echo -e "${GREEN}Create an alias to make shortcuts usable inside Termux."
	echo -e "${UYELLOW}Now can use 'start_box_proot' and 'kill_box_proot' in terminal, or by using Termux:Widget on the launcher.${WHITE}"
	echo 'alias start_box_proot="sh ~/.shortcuts/LaunchXFCE_proot"
	alias kill_box_proot="sh ~/.shortcuts/KillXFCE_proot"
	echo -e "start_box_proot - Launch the proot XFCE, Termux:X11\nkill_box_proot - Kill virgl server, pulseaudio, etc."' >> ~/.bashrc
	echo '${UYELLOW}Do not forget to "source ~/.bashrc" after script finish.${WHITE}'
}

# This will cleanup files that are not needed anymore.
cleanup(){
	echo -e "${GREEN}Clean downloaded resources (Termux_X11, Termux_widget, etc.).${WHITE}"
	rm -r Termux_X11
	rm termux-widget_v0.13.0+github-debug.apk
}

# Function to run a function, perform exit status check, and pause with read timeout.
function rftc() {
    local func_name=$1
    local timeout=$2

    echo -e "${GREEN}Running step: ${func_name}.${WHITE}"
    $func_name
	
	# Check if every command inside the function is executed successfully.
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}${func_name} completed successfully.${WHITE}"
    else
        echo -e "${URED}${func_name} encountered an error.${WHITE}"
		echo -e "${UYELLOW}Please use the 'cd termux-chroot-proot-wine-box86_64', './Scripts/Addons_Menu.sh' and select remove script or delete Termux App data and try again.${WHITE}"
		echo -e "Error can be from network, incompatibility, outdated 'X11_ARTIFACT_LINK' or script problem due Termux / Android updates."
		exit 2
    fi

    echo -e "${GREEN}Pausing for ${timeout} seconds...${WHITE}"
	echo -e "Press any key to skip the pause."
    read -t $timeout -n 1 -s -r
}

# Run everything in sequencial order
rftc update_install_base_packages 2
rftc install_termux_x11_pkg_app 2
rftc setup_ubuntu_proot 2
rftc install_termux_widget_app 2
rftc create_shortcuts_for_widget 2
rftc add_bash_alias_for_shortcuts 2
rftc cleanup 1

echo -e "${GREEN}Enjoy. Check out the markdown files in the git for more details.${WHITE}"
echo -e "${UYELLOW}You can install some addons, Box Bash, Steam, Zink, etc. using: 'cd termux-chroot-proot-wine-box86_64' then './Scripts/Addons_Menu.sh'.${WHITE}"
