
# Running Linux GUI apps on Android using Ubuntu in chroot, Magisk and Termux

This guide will show you how to run Linux GUI apps on your Android device using chrooted Ubuntu 22.04, Magisk and Termux. GPU hardware acceleration configuration using virgl.

Please note that you need a rooted device with Magisk installed to follow this guide. 

You will find how to create a Termux shortcut to run this fast, at the end.

Tested on Xiaomi Mi 6, Snapdragon 835 - Adreno 540 GPU, Android 13 - LineageOS 20.0 - Kernel 4.4.302.

## Prerequisites

- Rooted Android device with Magisk installed;
- Magisk modules: [lhroot](https://github.com/FerryAr/lhroot) and [BuiltIn-BusyBox](https://github.com/Magisk-Modules-Alt-Repo/BuiltIn-BusyBox);
- Device /data - /userdata - is not encrypted;
- If you are on Android 12+, apply these [adb commands](https://github.com/HardcodedCat/termux-monet#deactivation-instructions-adb)
to fix Phantom Processes Kill - [issues thread](https://github.com/termux/termux-app/issues/2366#issuecomment-955149284). 
You can use [adb over Wi-Fi](https://github.com/termux/termux-app/issues/2366#issuecomment-1250203447) inside Termux. 
[Video tutorial](https://www.youtube.com/watch?v=OZny45wLZL4). 
There's a [Magisk module](https://github.com/HardcodedCat/termux-monet#experimental-method-magisk) which does this automatically at every bot.
Note: **Skip on custom ROM**: I didn't need to do this for the LineageOS;

You can install Magisk modules using [Fox's Magisk Module Manager](https://github.com/Fox2Code/FoxMagiskModuleManager).

Device encryption can be disabled using the flashable zip from [this XDA thread](https://forum.xda-developers.com/t/deprecated-universal-dm-verity-forceencrypt-disk-quota-disabler-11-2-2020.3817389/).

If you don't want to disable encryption, then you can use a [loop device](https://github.com/ivon852/netlify-ivon-blog-comments/discussions/454#discussioncomment-5273965) but set up the chroot [manually](https://ivonblog.com/en-us/posts/termux-chroot-ubuntu/).

## Instructions
### Basic set up

Make sure Termux packages are updated:

    pkg update -y && pkg upgrade -y
	
Optional: If you want, you can use ssh on your PC, port 8022:

	pkg install sshd
	passwd
	sshd
	ifconfig

Install required packages in Termux:

    pkg install root-repo x11-repo
	pkg update
	pkg install tsu pulseaudio virglrenderer-android

Optional: Set SELinux to permissive:

    sudo setenforce 0

Create an Ubuntu Linux chroot:

    sudo lhroot

Start virgl server for GPU hardware acceleration:

    virgl_test_server_android &

Chroot into the created Ubuntu distro:

    sudo bootlinux

Do some basic settings inside chroot:

    echo "nameserver 1.1.1.1" >> /etc/resolv.conf
    echo "127.0.0.1 localhost" > /etc/hosts
    groupadd -g 3003 aid_inet
    groupadd -g 3004 aid_net_raw
    groupadd -g 1003 aid_graphics
    usermod -g 3003 -G 3003,3004 -a _apt
    usermod -G 3003 -a root
	add-apt-repository ppa:kisak/kisak-mesa
    apt update -y && apt upgrade -y

Fix the debconf errors:

    apt install -y dialog apt-utils

Install necessary packages to run XFCE4, etc.:

    apt install -y psmisc htop software-properties-common wget dbus-x11 xfce4 xfce4-terminal mesa-utils mesa-vulkan-drivers

### Graphic environment

#### Xserver XSDL - fast set up
**Optional**: If you want to use [Xserver XSDL app](https://play.google.com/store/apps/details?id=x.org.server&hl=en_US), then open app and inside chroot:

    export DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1:4713 
    dbus-launch --exit-with-session startxfce4 &

#### Termux:X11 - recommended
If you want to use Termux:X11, exit chroot:

    exit
	
Unpack Termux:X11 latest zip from [termux-x11 builds](https://github.com/termux/termux-x11/actions/workflows/debug_build.yml) (click on a build and check ***Artifacts*** section) to a directory, e.g. Download/termux-x11, and install the .apk.
Note: enable Termux:X11 notification from the phone apps settings.

Install Termux:X11 package inside Termux:

    termux-setup-storage
	pkg install -y xwayland
	dpkg -i ~/storage/downloads/termux-x11/termux-x11*.deb
	sed '/allow-external-apps/s/^# //' -i ~/.termux/termux.properties
	termux-reload-settings

Open Termux:X11 app and, inside Termux:

    XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :0 -ac &

Mount Termux /tmp to the chroot, for X11 access:

Note: you need this for having access to termux-x11 [wayland socket](https://github.com/termux/termux-x11#how-does-it-work) inside chroot.

    export CHROOT_DIR=/data/ubuntu
    sudo busybox mount --bind $PREFIX/tmp $CHROOT_DIR/tmp

Start PulseAudio server:

    pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
    pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1

Go back to chroot and launch XFCE4:

    sudo bootlinux
    chmod -R 777 /tmp
    export DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1:4713
    dbus-launch --exit-with-session startxfce4 &

### Hardware acceleration 

As the installed mesa already support virgl, you should be able to run apps using virgl. 

Using mesa-utils to check for the actual rendering performance, llvmpipe, CPU:

    export DISPLAY=:0
	glxgears
	
Snapdragon 835, Adreno 540:
191 FPS

For some apps, you need to specify MESA_GL_VERSION_OVERRIDE version, with GPU:

    GALLIUM_DRIVER=virpipe glxgears
	
250 FPS

Sadly, I think there's something wrong with the Kernel or Android 13 on this phone, as Termux and chroot can't use GPU and CPU at 100%.

### Termux:Widget shortcut

Create a startup script compatible with [Termux:Widget](https://github.com/termux/termux-widget/releases/) app:
Note: install [Termux:API](https://wiki.termux.com/wiki/Termux:API) and `pkg install termux-api` if you want toast message.

    mkdir .shortcuts
    echo '#!/bin/sh
    export CHROOT_DIR=/data/ubuntu
    killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android
    termux-wake-lock; termux-toast "Starting X11"
    am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity 
    sudo busybox mount --bind $PREFIX/tmp $CHROOT_DIR/tmp
    XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :0 -ac &
	sleep 3
    pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
    pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
    virgl_test_server_android &
    su -c "(source bootlinux_env $CHROOT_DIR &&$busybox chroot $CHROOT_DIR /usr/bin/env su -l -c\
    \"export DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1:4713 && dbus-launch --exit-with-session startxfce4 &\")"' > ~/.shortcuts/LaunchXFCE_lhroot

Create a kill script compatible with Termux:Widget app:

    echo '#!/bin/sh
    export CHROOT_DIR=/data/ubuntu
    killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android
    termux-wake-unlock; termux-toast "Stopping X11, chroot, etc."
    sudo busybox umount $CHROOT_DIR/tmp
    sudo killlinux $CHROOT_DIR' > ~/.shortcuts/KillXFCE_lhroot
	
**Optional**: Create a start script for ssh server:

    echo '#!/bin/sh
	termux-wake-lock; sshd &
	echo "Connect using device IP, 8022 port"' > ~/.shortcuts/StartSSHD

Add the Termux widget on your screen, from launcher widgets, so you can start everything with one touch.

### Explore alternative hardware acceleration methods:

Check the [Hardware Acceleration Resources](/blob/main/Hardware_Acceleration_Resources.md).