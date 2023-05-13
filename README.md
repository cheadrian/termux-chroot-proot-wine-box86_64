# Termux chroot / proot with Wine, Box86, and GPU

## Getting started

You can set up everything using this command in Termux (Github version):

    pkg update -y && pkg install -y wget && wget https://raw.githubusercontent.com/cheadrian/termux-chroot-proot-wine-box86_64/main/Scripts/Getting_Started.sh && chmod +x Getting_Started.sh && ./Getting_Started.sh && rm Getting_Started.sh
	
This script will:
- Clone this git and scripts;
- Create an Ubuntu proot with alias ubuntu_box86;
- Install Termux:X11 app and package, Termux:Widget app;
- Add packages as pulseaudio, virglrenderer, xwayland, etc.;
- Create shortcuts to launch XFCE in proot using the Termux:Widget;
- Set up the proot with Box86, Box64, Wine32 and Wine64;

[Addons_Menu.sh](Scripts/Addons_Menu.sh): Let you to install mesa with zink and virgl zink, Steam (not working fully yet), add bash I386 and bash AMD64 for Box86_64, add an user to proot, compile GL4ES, etc. .

## Docs

![Collage with Call of Duty 2, Euro Truck Simulator, Portal](https://raw.githubusercontent.com/cheadrian/termux-chroot-proot-wine-box86_64/main/Games_Collage.png)

This git repository contains several markdown files that provide information and instructions for setting up and using various hardware acceleration and software tools on Android devices. The files are as follows:

- [Setup_Chroot_Magisk.md](Setup_Chroot_Magisk.md): For devices with **ROOT**. Use proot if you don't have root. This file provides instructions for running Linux GUI apps on Android using Ubuntu in chroot, Magisk, and Termux. It covers topics such as installing Magisk modules, setting up a chroot environment with Ubuntu, and launching Linux GUI apps.

- [Setup_Proot.md](Setup_Proot.md): This file provides instructions for running Linux GUI apps on Android using Ubuntu in proot Termux. It covers topics such as setting up a proot environment with Ubuntu, and launching Linux GUI apps.

- [Setup_Wine_Box86_64.md](Setup_Wine_Box86_64.md): This file provides instructions for installing Wine32, Wine64, Box86, and Box64 on Android using Termux Ubuntu 22.04 proot / chroot. It covers topics such as installing dependencies and launching Wine, Winetricks, and Windows apps.

- [Hardware_Acceleration_Resources.md](Hardware_Acceleration_Resources.md): This file contains a list of resources for hardware acceleration on Termux proot / chroot. It includes a basic collection of information that will help you to get your GPU running.

Each markdown file includes detailed instructions and resources for setting up and using the respective tool or technology. Feel free to explore and use these files as a guide for enhancing your Android device with new capabilities.