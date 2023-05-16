# Steam set up for Box and Wine on Termux proot

Run everything inside your Ubuntu 22.04 proot. I didn't test this yet using chroot.

[Addons_Proot_Steam.sh](Scripts/Addons_Proot_Steam.sh) will do this for you. Make sure you run it through [Addons_Menu.sh](Scripts/Addons_Menu.sh).

Steam Linux on your device using Box86. It requires the use of 'proot' without **'--no-sysvipc'**.

## Problems

Sadly, some devices can't run all proot functions without '--no-sysvipc'.
You can use two separate proot, one with '--no-sysvipc' and another one without it, just for Steam, using the same distro.
This is how I've handled it within the script.

Lack of binfmt can be replace with Boxed bash:
https://box86.org/2022/09/running-bash-with-box86-box64/

For now (12 May 2023): it throws 'Fatal error: futex robust_list not initialized by pthreads' error.

See updates here: 
https://github.com/ptitSeb/box86/issues/770

## Installation

For now, I don't write a direct guide. Please follow [the script](Scripts/Addons_Proot_Steam.sh) mentioned above.

## Alternative

You can install and run the Windows version of Steam through the [PlayOnLinux](Setup_PlayOnLinux.md) or set it up with already installed Wine. Use "-oldbigpicture -bigpicture -windowed -login someotherusername somepassword" as arguments. Check out [here](https://steamcommunity.com/discussions/forum/0/3758852249527312123/) for more support.

Note: oldbigpicture will have low FPS without hardware acceleration.

Example command using system installed wine:

    wine Steam.exe -oldbigpicture -bigpicture -windowed -login anonymous
    
For the moment it doesn't display text, probably due missing fonts, but you can login and use the functions. Installing corefonts (Microsoft Core Fonts) and allfonts through winetricks / PlayOnLinux doesn't make a difference.

    winetricks32 corefonts
    winetricks32 allfonts
	
Other options to open Steam doesn't work with the current version, as it open just a black window.