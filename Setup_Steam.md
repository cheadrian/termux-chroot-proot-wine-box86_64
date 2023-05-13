# Steam set up for Box and Wine on Termux proot

Run everything inside your Ubuntu 22.04 proot. I didn't test this yet using chroot.

[Addons_Proot_Steam.sh](Scripts/Addons_Proot_Steam.sh) will do this for you. Make sure you run it through [Addons_Menu.sh](Scripts/Addons_Menu.sh).

Steam on your device using Box86. It requires the use of 'proot' without **'--no-sysvipc'**.

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