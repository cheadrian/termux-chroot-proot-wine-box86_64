#!/bin/bash -i

export GREEN='\033[0;32m'
export URED='\033[4;31m'
export UYELLOW='\033[4;33m'
export WHITE='\033[0;37m' 

echo -e "${GREEN}Using xDoge26 Mesa Turnip compatible with Adreno KGSL driver.${WHITE}"
echo -e "${GREEN}This will install the Turnip driver inside proot, and create a desktop shortcut to test.${WHITE}"
echo -e "${UYELLOW}It is compatible only with some of Qualcomm Adreno GPUs, like Adreno 650, and performance is not there yet, but probably better compatibility.${WHITE}"
echo -e "${UYELLOW}If you get download error, update download links in 'Addons_Proot_Mesa_Turnip.sh'.${WHITE}"
echo -e "Press any key to continue."
read -n 1 -s -r

echo -e "${GREEN}Download and install Vulakn KGSL.${WHITE}"
wget https://github.com/xDoge26/proot-setup/raw/main/Packages/mesa-vulkan-kgsl_23.3.0-devel-20230728_arm64.deb
wget https://github.com/xDoge26/proot-setup/raw/main/Packages/mesa-vulkan-kgsl_23.3.0-devel-20230728_armhf.deb

dpkg -i mesa-vulkan-kgsl_23.3.0-*

echo -e "${GREEN}Install vulkan tools.${WHITE}"
apt install -y vulkan-tools

echo -e "${GREEN}Create desktop shortcut for vkcube.${WHITE}"
echo '[Desktop Entry]
Name=VKCube Turnip
Exec=bash -c "env TU_DEBUG=noconform MESA_VK_WSI_DEBUG=sw vkcube"
Icon=vkcube
Terminal=true
Type=Application' > ~/Desktop/VKCube_turnip.desktop
chmod +x ~/Desktop/VKCube_turnip.desktop

echo -e "${GREEN}Now everything is setup, you can use this by calling Zink driver directly in proot, for OpenGL, or anything Vulakn compatible, like DXVK on Wine.${WHITE}"
echo -e "${GREEN}MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform MESA_VK_WSI_DEBUG=sw glxgears${WHITE}"
echo -e "${GREEN}Also check deviceName by using 'vulkaninfo --summary'.${WHITE}"