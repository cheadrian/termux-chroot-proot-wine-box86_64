#!/data/data/com.termux/files/usr/bin/bash

export GREEN='\033[0;32m'
export TURQ='\033[0;36m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m'
export PROOT_ROOT=$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu_box86/root
export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


echo -e "${GREEN}Run these actions only if you already have the proot with Box86_64 and Wine86_64 configured.";
echo -e "${GREEN}You can run this menu anytime using './Addons_Menu.sh' inside Termux.";
echo -e "${UYELLOW}Run these actions only if you already have the proot with Box86_64 and Wine86_64 configured.${WHITE}";
# read -p "What action do you want to perform? " yn
# # 1. Proot: Add new user named 'box'.
# # 2. Proot: Set up Bash x86 and x64 with Box86 and Box64.
# # 3. Proot: Install Steam in 'box' user using Box Bash.
# # 4. Termux: Set-up mesa-zink and compatible virgl server.
echo -e "${TURQ}1. Proot: Add new user named 'box'."
echo -e "${TURQ}2. Proot: Set up Bash x86 and x64 with Box86 and Box64."
echo -e "${TURQ}3. Proot: Install Steam. ${UYELLOW}NOTE: Doesn't start completely now."
echo -e "${TURQ}4. Termux: Set-up mesa-zink and compatible virgl server."
echo -e "${TURQ}5. Proot: Set-up GL4ES."
echo -e "${TURQ}6. Termux: Create alias shortcuts to enter in the Ubuntu proot."
echo -e "${TURQ}7. Proot: Install native PlayOnLinux with Box86_64 support."
echo -e "Anything else: exit.${WHITE}"

read -p "Please select an option:" opt
case $opt in 
	1 ) echo -e "${GREEN}Add the 'box' user.${WHITE}"
		cp $SCRIPT_DIR/Addons_Proot_Add_user.sh $PROOT_ROOT/Addons_Proot_Add_user.sh
		chmod +x $PROOT_ROOT/Addons_Proot_Add_user.sh
		proot-distro login ubuntu_box86 --user root --shared-tmp --no-sysvipc -- bash -c "./Addons_Proot_Add_user.sh"
		rm $PROOT_ROOT/Addons_Proot_Add_user.sh
		exit;;
	2 ) echo -e "${GREEN}Set up Bash x86 and x64.${WHITE}"
		cp $SCRIPT_DIR/Addons_Proot_Box86_64_Bash.sh $PROOT_ROOT/Addons_Proot_Box86_64_Bash.sh
		chmod +x $PROOT_ROOT/Addons_Proot_Box86_64_Bash.sh
		proot-distro login ubuntu_box86 --user root --shared-tmp --no-sysvipc -- bash -c "./Addons_Proot_Box86_64_Bash.sh"
		rm $PROOT_ROOT/Addons_Proot_Box86_64_Bash.sh
		exit;;
	3 ) echo -e "${GREEN}Install Steam.${WHITE}"
		cp $SCRIPT_DIR/Addons_Proot_Add_user.sh $PROOT_ROOT/Addons_Proot_Add_user.sh
		cp $SCRIPT_DIR/Addons_Proot_Box86_64_Bash.sh $PROOT_ROOT/Addons_Proot_Box86_64_Bash.sh
		cp $SCRIPT_DIR/Addons_Proot_Steam.sh $PROOT_ROOT/Addons_Proot_Steam.sh
		chmod +x $PROOT_ROOT/Addons_Proot_Add_user.sh
		chmod +x $PROOT_ROOT/Addons_Proot_Box86_64_Bash.sh
		chmod +x $PROOT_ROOT/Addons_Proot_Steam.sh
		proot-distro login ubuntu_box86 --user root --shared-tmp -- bash -i -c "./Addons_Proot_Steam.sh"
		rm $PROOT_ROOT/Addons_Proot_Steam.sh
		rm $PROOT_ROOT/Addons_Proot_Add_user.sh
		rm $PROOT_ROOT/Addons_Proot_Box86_64_Bash.sh
		echo -e "${GREEN}Add shortcut to Termux:Widget for Steam.${WHITE}"
		echo -e '#!/bin/sh\necho "Please make sure you already running the XFCE and Termux:X11!"\nsleep 1\nproot-distro login ubuntu_box86 --user root --shared-tmp -- bash -i -c "sudo -E -H -u box box86 steam"' > ~/.shortcuts/LaunchSteam_proot
		chmod +x ~/.shortcuts/LaunchSteam_proot
		exit;;
	4 ) echo -e "${GREEN}Adding tur-repo and install mesa-zink.${WHITE}"
	    chmod +x $SCRIPT_DIR/Addons_Termux_Mesa_Zink_VirGL.sh
		$SCRIPT_DIR/Addons_Termux_Mesa_Zink_VirGL.sh
		exit;;
	5 ) echo -e "${GREEN}Set up Bash x86 and x64.${WHITE}"
		cp $SCRIPT_DIR/Addons_Proot_GL4ES.sh $PROOT_ROOT/Addons_Proot_GL4ES.sh
		chmod +x $PROOT_ROOT/Addons_Proot_GL4ES.sh
		proot-distro login ubuntu_box86 --user root --shared-tmp --no-sysvipc -- bash -c "./Addons_Proot_GL4ES.sh"
		rm $PROOT_ROOT/Addons_Proot_GL4ES.sh
		exit;;
	6 ) echo -e "${GREEN}Adding a shortcut to enter in the proot.${WHITE}"
	    chmod +x $SCRIPT_DIR/Addons_Termux_Ubuntu_Box.sh
		$SCRIPT_DIR/Addons_Termux_Ubuntu_Box.sh
		exit;;
	7 ) echo -e "${GREEN}Install the PlayOnLinux.${WHITE}"
		cp $SCRIPT_DIR/Addons_Proot_PlayOnLinux_Box.sh $PROOT_ROOT/Addons_Proot_PlayOnLinux_Box.sh
		chmod +x $PROOT_ROOT/Addons_Proot_PlayOnLinux_Box.sh
		proot-distro login ubuntu_box86 --user root --shared-tmp --no-sysvipc -- bash -c "./Addons_Proot_PlayOnLinux_Box.sh"
		rm $PROOT_ROOT/Addons_Proot_PlayOnLinux_Box.sh
		exit;;
	* ) echo -e "${GREEN}Goodbye :)!.${WHITE}"
		exit;;
esac