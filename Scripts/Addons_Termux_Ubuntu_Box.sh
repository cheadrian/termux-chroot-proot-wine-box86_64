#!/bin/bash

export GREEN='\033[0;32m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m' 	

echo -e "${GREEN}This will create a simple shortcut, .bashrc alias, to enter in the Ubuntu proot.${WHITE}"
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"

echo -e "${GREEN}Add alias to .bashrc.${WHITE}"

echo 'alias enter_box_proot="proot-distro login ubuntu_box86 --user root --shared-tmp --no-sysvipc"
alias enter_box_proot_nsysv="proot-distro login ubuntu_box86 --user root --shared-tmp"
echo -e "enter_box_proot - Shortcut to proot-distro command with --no-sysvipc\nenter_box_proot_sysv - Without the --no-sysvipc"' >> ~/.bashrc
source ~/.bashrc

echo -e "${UYELLOW}Now you can use 'enter_box_proot' and 'enter_box_proot_sysv'.${WHITE}"
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"