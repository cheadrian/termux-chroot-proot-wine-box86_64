#!/bin/bash

export GREEN='\033[0;32m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m' 	

echo -e "${GREEN}This will install the mesa-zink and compatible VirGL server through Termux tur-repo."
echo -e "${GREEN}It also adds a shortcut for Termux:Widget and .bashrc alias to run the proot XFCE."
echo -e "${GREEN}It can increase performance on some devices with proper Vulkan support.${WHITE}"
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"
echo -e "${GREEN}Add the tur-repo.${WHITE}"
pkg add -y tur-repo
pkg update -y p

echo -e "${GREEN}Install mesa-zink and Zink compatible virgl.${WHITE}"
pkg install -y mesa-zink virglrenderer-mesa-zink

echo -e "${GREEN}Create Termux:Widget shortcut. Adding alias 'start_box_proot_zink'.${WHITE}"
echo '#!/bin/sh
killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android virgl_test_server
termux-wake-lock; termux-toast "Starting X11"
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity
XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :0 -ac & 
sleep 3
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.5COMPAT MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink ZINK_DESCRIPTORS=lazy virgl_test_server --use-egl-surfaceless --use-gles &
proot-distro login ubuntu_box86 --user root --shared-tmp --no-sysvipc -- bash -c "export DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1:4713; dbus-launch --exit-with-session startxfce4"' > ~/.shortcuts/LaunchXFCE_proot_zink
chmod +x ~/.shortcuts/LaunchXFCE_proot_zink

echo 'alias start_box_proot_zink="sh ~/.shortcuts/LaunchXFCE_proot_zink"
echo -e "start_box_proot_zink - Launch the proot XFCE with Zink virgl, Termux:X11"' >> ~/.bashrc
source ~/.bashrc

echo -e "${GREEN}Start the proot with the new shortcut."
echo -e "${UYELLOW}Now you can start the proot XFCE and use the Zink VirGL server, like before: 'GALLIUM_DRIVER=virpipe'.${WHITE}"
echo -e "${UYELLOW}Note: Zink VirGL server it's still experimental.${WHITE}"
read -n 1 -s -r -p "Press any key to continue."
echo -e "${WHITE}"