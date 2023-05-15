# PlayOnLinux set up for Box86_64 on Termux proot

Run everything inside your Ubuntu 22.04 proot. I didn't test this yet using chroot.

[Addons_Proot_PlayOnLinux_Box.sh](Scripts/Addons_Proot_PlayOnLinux_Box.sh) will do this for you. Make sure you run it through [Addons_Menu.sh](Scripts/Addons_Menu.sh).

## Problems

Lack of binfmt can affect how the PlayOnLinux will run the x86 or x64 Wine version, but luckly [Bash Box86_64](https://box86.org/2022/09/running-bash-with-box86-box64/) and undocumented [BEFORE_WINE](https://github.com/PlayOnLinux/POL-POM-4/blob/d43771e73cdb9bdeb55fee7de14c2d182543ef6f/lib/wine.lib#L544) prefix can help to mitigate these problems.

## Installation

Installation is quite simple and basic.

    apt install -y playonlinux

## Running

The only difference is that you will have to mention what the Box86_64 version you want to use in order to run Wine, through the `BEFORE_WINE` flag. E.g.:

    BEFORE_WINE=box86 playonlinux
	BEFORE_WINE=box64 box64 playonlinux
	
Note that the PlayOnLinux would not run as root, so you need to run it as another user.