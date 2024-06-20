
# Running Linux GUI apps on Android using Ubuntu in proot Termux

This guide will show you how to run Linux GUI apps on your Android device using prooted Ubuntu 22.04, Magisk and Termux. GPU hardware acceleration configuration using virgl.

Please note that you need a rooted device with Magisk installed to follow this guide. 

You will find how to create a Termux shortcut to run this fast, at the end.

Tested on:

- Xiaomi POCO F2 PRO, Snapdragon 865 - Adreno 650, Android 12 - MIUI 14.0.1 - Kernel 4.19.157.

- Huawei MatePad 10.4 2021, Kirin 810 - Mali-G52 - Android 10 - HarmonyOS.

## Prerequisites

- If you are on Android 12+, apply these [adb commands](https://github.com/HardcodedCat/termux-monet#deactivation-instructions-adb) at boot to fix Phantom Processes Kill - [issues thread](https://github.com/termux/termux-app/issues/2366#issuecomment-955149284).  You can use [adb over Wi-Fi](https://github.com/termux/termux-app/issues/2366#issuecomment-1250203447) inside Termux.  [Video tutorial](https://www.youtube.com/watch?v=OZny45wLZL4). 

## Instructions
### Basic set up

Make sure Termux packages are updated:

    pkg update -y && pkg upgrade -y
	
Optional: If you want, you can use ssh on your PC, port 8022:

	pkg install -y openssh
	passwd
	sshd
	ifconfig

Install required packages in Termux:

    pkg install -y x11-repo
	pkg update -y
	pkg install -y pulseaudio virglrenderer-android proot-distro

Start virgl server for GPU hardware acceleration:

    virgl_test_server_android &
	
Create a prooted Ubuntu:

    proot-distro install ubuntu

Proot into the created Ubuntu distro:

Note: I use `--no-sysvipc` because of the [BadShmSeg issue](https://github.com/termux/termux-x11/issues/234). `--shared-tmp` to have access to termux-x11 [wayland socket](https://github.com/termux/termux-x11#how-does-it-work) inside proot.

    proot-distro login ubuntu --user root --shared-tmp --no-sysvipc

Fix the debconf errors:

    apt update -y && apt upgrade -y
    apt install -y dialog apt-utils

Install necessary packages to run XFCE4, etc.:

    apt install -y psmisc htop software-properties-common wget mesa-utils dbus-x11 xfce4 xfce4-terminal

### Graphic environment

#### Xserver XSDL - fast set up
**Optional**: If you want to use [Xserver XSDL app](https://play.google.com/store/apps/details?id=x.org.server&hl=en_US), then open app and inside proot:

    export DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1:4713 
    dbus-launch --exit-with-session startxfce4 &

#### Termux:X11 - recommended
If you want to use Termux:X11, exit proot:

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

Start PulseAudio server:

    pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
    pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1

Go back to proot and launch XFCE4:

    proot-distro login ubuntu --user root --shared-tmp --no-sysvipc
    export DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1:4713
    dbus-launch --exit-with-session startxfce4 &

(in proot )
export DISPLAY=:0
startxfce4

### Hardware acceleration

You should be able to run apps using virgl. Using mesa-utils to check for the actual rendering performance:

    glxgears

For some apps, you need to specify MESA_GL_VERSION_OVERRIDE version:

    GALLIUM_DRIVER=virpipe glxgears
	
If you need, for some reason, to compile mesa from source, check the ***Hardware Acceleration Resources*** at the bottom.

### Termux:Widget shortcut

Create a startup script compatible with [Termux:Widget](https://github.com/termux/termux-widget/releases/) app:
Note: install [Termux:API](https://wiki.termux.com/wiki/Termux:API) and `pkg install termux-api` if you want toast message.

    mkdir .shortcuts
    echo '#!/bin/sh
    killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android
    termux-wake-lock; termux-toast "Starting X11"
    am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity
	XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :0 -ac & 
	sleep 3
    pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
    pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
    virgl_test_server_android &
    proot-distro login ubuntu --user root --shared-tmp --no-sysvipc -- bash -c "export DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1:4713; dbus-launch --exit-with-session startxfce4"' > ~/.shortcuts/LaunchXFCE_proot

Create a kill script compatible with Termux:Widget app:

    echo '#!/bin/sh
    killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android
    termux-wake-unlock; termux-toast "Stopping X11, virgl, etc."' > ~/.shortcuts/KillXFCE_proot
	
**Optional**: Create a start script for ssh server:

    echo '#!/bin/sh
	termux-wake-lock; sshd &
	echo "Connect using device IP, 8022 port"' > ~/.shortcuts/StartSSHD

Add the Termux widget on your screen, from launcher widgets, so you can start everything with one touch.

### Explore alternative hardware acceleration methods:

Check the [Hardware Acceleration Resources](Hardware_Acceleration_Resources.md).
