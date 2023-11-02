# Termux chroot / proot with Wine, Box86, and GPU

## Getting started

You can set up everything using this command in Termux (Github version):

    yes | pkg update -y && pkg install -y wget && wget https://raw.githubusercontent.com/cheadrian/termux-chroot-proot-wine-box86_64/main/Scripts/Getting_Started.sh && chmod +x Getting_Started.sh && ./Getting_Started.sh && rm Getting_Started.sh
	
I recommend you to try [Winlator](https://winlator.com/), as it have a nice interface and can run X86, X64 programs almost the same as this script. Of course you will give up advanced customization and picking a custom version of Wine 🫠.

This script will:
- Clone this git and scripts;
- Create an Ubuntu proot with alias ubuntu_box86;
- Install Termux:X11 app and package, Termux:Widget app;
- Add packages as pulseaudio, virglrenderer, xwayland, etc.;
- Create shortcuts to launch XFCE in proot using the Termux:Widget;
- Set up the proot with Box86, Box64, Wine32 and Wine64;

[Addons_Menu.sh](Scripts/Addons_Menu.sh): Let you, in:
- Termux: Set-up mesa-zink and compatible virgl server.
- Termux: Create an alias to enter in Ubuntu proot.
- Proot: Add new user named 'box'.
- Proot: Set up Bash x86 and x64 with Box86 and Box64.
- Proot: Install Steam. NOTE: Doesn't start completely now.
- Proot: Compile and install GL4ES.
- Proot: Install native PlayOnLinux with Box86_64 support.
- Proot: Install Mesa Turnip Adreno KGSL compatible driver.

Current versions: Wine 8.7 from [Wine-Builds](https://github.com/Kron4ek/Wine-Builds), latest Box86_64 from [ryanfortner](https://github.com/ryanfortner), [Termux:Widget v0.13](https://github.com/termux/termux-widget/releases/tag/v0.13.0) (Github), [Termux:X11 v1.02.07](https://github.com/termux/termux-x11/actions/runs/4524914392) (Github).

Now you can pick from Wine versions: 8.13, 8.7, 7.22, 6.23, 5.22.

## Docs

![Collage with Call of Duty 2, Euro Truck Simulator, Portal](https://raw.githubusercontent.com/cheadrian/termux-chroot-proot-wine-box86_64/main/Games_Collage.png)

This git repository contains several markdown files that provide information and instructions for setting up and using various hardware acceleration and software tools on Android devices. The files are as follows:

- [Setup_Chroot_Magisk.md](Setup_Chroot_Magisk.md): For devices with **ROOT**. Use proot if you don't have root. This file provides instructions for running Linux GUI apps on Android using Ubuntu in chroot, Magisk, and Termux. It covers topics such as installing Magisk modules, setting up a chroot environment with Ubuntu, and launching Linux GUI apps.

- [Setup_Proot.md](Setup_Proot.md): This file provides instructions for running Linux GUI apps on Android using Ubuntu in proot Termux. It covers topics such as setting up a proot environment with Ubuntu, and launching Linux GUI apps.

- [Setup_Wine_Box86_64.md](Setup_Wine_Box86_64.md): This file provides instructions for installing Wine32, Wine64, Box86, and Box64 on Android using Termux Ubuntu 22.04 proot / chroot. It covers topics such as installing dependencies and launching Wine, Winetricks, and Windows apps.

- [Hardware_Acceleration_Resources.md](Hardware_Acceleration_Resources.md): This file contains a list of resources for hardware acceleration on Termux proot / chroot. It includes a basic collection of information that will help you to get your GPU running.

- [Setup_Steam.md](Setup_Steam.md): Provides detail and hints about how you can run Steam using the environment set up as above.

- [Setup_PlayOnLinux.md](Setup_PlayOnLinux.md): You can check how you can get, with ease, get the PlayOnLinux to use Box86_64 inside the proot.

Each markdown file includes detailed instructions and resources for setting up and using the respective tool or technology. Feel free to explore and use these files as a guide for enhancing your Android device with new capabilities.

# Alternatives

Other interesting projects that can bring you Box86_64 in Termux:

- [Box64Droid](https://github.com/Ilya114/Box64Droid)

- [AnBox86](https://github.com/lowspecman420/AnBox86)

# License and 3rd party

For what you find in this git, [Unlicense](https://opensource.org/license/unlicense/).

Other 3rd party apps and packages: [Termux-app](https://github.com/termux/Termux-app), [Termux-x11](https://github.com/termux/termux-x11), [Termux-Widget](https://github.com/termux/termux-widget), [Proot-distro](https://github.com/termux/proot-distro), [TUR repo](https://github.com/termux-user-repository/tur), [Box86](https://github.com/ptitSeb/box86), [Box64](https://github.com/ptitSeb/box64), [Wine](https://github.com/wine-mirror/wine), [Winetricks](https://github.com/Winetricks/winetricks), [PlayOnLinux](https://github.com/PlayOnLinux/POL-POM-4).
