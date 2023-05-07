# Wine32, Wine64, Box86 and Box64 installation on Android using Termux Ubuntu 22.04 proot / chroot

Run everything inside your Ubuntu 22.04 chroot / proot.

## Add repo for Box86_64

### [Box64](https://box64.debian.ryanfortner.dev/), [(1)](https://github.com/ptitSeb/box64/blob/main/docs/COMPILE.md):

    wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list
    wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
	
### Box86:
	
	wget https://ryanfortner.github.io/box86-debs/box86.list -O /etc/apt/sources.list.d/box86.list
	wget -qO- https://ryanfortner.github.io/box86-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg 
	
## Installation:

### Box86_64

	apt update -y
	apt install box64-android -y

For box86 you need a multiarch:

Note: "You NEED a 32-bit subsystem to run and build Box86.".

	dpkg --add-architecture armhf
	apt update -y
	apt install libc6:armhf -y
	apt install box86-android:armhf -y
	
### Wine-x86 and Wine-AMD64

Install some necessary packages:

    apt install nano cabextract libfreetype6 libfreetype6:armhf libfontconfig libfontconfig:armhf libxext6 libxext6:armhf libxinerama-dev libxinerama-dev:armhf libxxf86vm1 libxxf86vm1:armhf libxrender1 libxrender1:armhf libxcomposite1 libxcomposite1:armhf libxrandr2 libxrandr2:armhf libxi6 libxi6:armhf libxcursor1 libxcursor1:armhf libvulkan-dev libvulkan-dev:armhf
	
If you already add armhf as arch, then you can install both Wine32 and Wine64 like below, [check here for latest version](https://github.com/Kron4ek/Wine-Builds/releases):

    cd ~/
	wget https://github.com/Kron4ek/Wine-Builds/releases/download/8.0.1/wine-8.0.1-amd64.tar.xz
	wget https://github.com/Kron4ek/Wine-Builds/releases/download/8.0.1/wine-8.0.1-x86.tar.xz
	tar xvf wine-8.0.1-amd64.tar.xz
	tar xvf wine-8.0.1-x86.tar.xz
	rm wine-8.0.1-amd64.tar.xz wine-8.0.1-x86.tar.xz
	mv wine-8.0.1-amd64 wine64
	mv wine-8.0.1-x86 wine
	
Then you can add these to your ~/.profile or ~/.bashrc:

	echo 'export DISPLAY=:0
	export BOX86_PATH=~/wine/bin/
	export BOX86_LD_LIBRARY_PATH=~/wine/lib/wine/i386-unix/:/lib/i386-linux-gnu/:/lib/aarch64-linux-gnu/:/lib/arm-linux-gnueabihf/:/usr/lib/aarch64-linux-gnu/:/usr/lib/arm-linux-gnueabihf/:/usr/lib/i386-linux-gnu/
	export BOX64_PATH=~/wine64/bin/
	export BOX64_LD_LIBRARY_PATH=~/wine64/lib/i386-unix/:~/wine64/lib/wine/x86_64-unix/:/lib/i386-linux-gnu/:/lib/x86_64-linux-gnu:/lib/aarch64-linux-gnu/:/lib/arm-linux-gnueabihf/:/usr/lib/aarch64-linux-gnu/:/usr/lib/arm-linux-gnueabihf/:/usr/lib/i386-linux-gnu/:/usr/lib/x86_64-linux-gnu' >> ~/.bashrc
	
	source ~/.bashrc
	
Create shortcuts for the wine with box:

	echo '#!/bin/bash 
	export WINEPREFIX=~/.wine32
	box86 '"$HOME/wine/bin/wine "'"$@"' > /usr/local/bin/wine
	chmod +x /usr/local/bin/wine
	echo '#!/bin/bash 
	export WINEPREFIX=~/.wine64
	box64 '"$HOME/wine64/bin/wine64 "'"$@"' > /usr/local/bin/wine64
	chmod +x /usr/local/bin/wine64
	
## Running
	
You can use Wine like this:

	box86 wine
	box64 wine64
	
Let's configure Wine with cfg tool:

	WINEPREFIX=~/.wine32 box86 wine winecfg
	WINEPREFIX=~/.wine64 box64 wine64 winecfg
	
You can also use the equivalent command that we've put inside the /bin, e.g.:

	wine winecfg
	wine64 winecfg
	
**Note**: you will need to set `WINEPREFIX` if you want to use both 32-bit and 64-bit version of wine.
Default is `~/.wine` for both 32-bit and 64-bit version, which will enter in conflict.

You might want to increase dpi inside "Graphics" tab.

## Testing

Test by installing Notepad++ 32-bit and 64-bit:

	cd ~/Downloads/
	wget https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.5.2/npp.8.5.2.Installer.exe
	wget https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.5.2/npp.8.5.2.Installer.x64.exe
	wine npp.8.5.2.Installer.exe
	wine64 npp.8.5.2.Installer.x64.exe
	
**Note**: Wine64 is capable to run 32-bit binaries also. You can stick with 64-bit for most of the time.

    wine64 ~/.wine32/drive_c/Program\ Files/Notepad++/notepad++.exe
	
## Winetricks

Install winetricks:

	cd ~/
	wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
	chmod +x winetricks
	mv winetricks /usr/local/bin/
	
Create shortcuts for the winetricks:

	echo '#!/bin/bash 
	export BOX86_NOBANNER=1 WINE=wine WINEPREFIX=~/.wine32 WINESERVER=~/wine/bin/wineserver
	wine '"/usr/local/bin/winetricks "'"$@"' > /usr/local/bin/winetricks32
	chmod +x /usr/local/bin/winetricks32
	echo '#!/bin/bash 
	export BOX64_NOBANNER=1 WINE=wine64 WINEPREFIX=~/.wine64 WINESERVER=~/wine64/bin/wineserver
	wine64 '"/usr/local/bin/winetricks "'"$@"' > /usr/local/bin/winetricks64
	chmod +x /usr/local/bin/winetricks64
	
Optional: Install zenity for Winetricks GUI:

	apt install zenity
	
Optional: Run Winetricks GUI:
	
	winetricks32 --gui
	winetricks64 --gui
	
Optional: Example of installing .NET 2.0 using Winetricks:

	winetricks32 dotnet20sp2
	winetricks64 dotnet20sp2
	 
## Create desktop and menu shortcuts

Shortcuts for wine32 and 64-bit:

    cd ~/Desktop
    echo '[Desktop Entry]
    Name=Wine32 Explorer
    Exec=bash -c "wine explorer"
    Icon=wine
    Type=Application' > ~/Desktop/Wine32_Explorer.desktop
	chmod +x ~/Desktop/Wine32_Explorer.desktop
	cp ~/Desktop/Wine32_Explorer.desktop /usr/share/applications/

    cd ~/Desktop
    echo '[Desktop Entry]
    Name=Wine64 Explorer
    Exec=bash -c "wine64 explorer"
    Icon=wine
    Type=Application' > ~/Desktop/Wine64_Explorer.desktop
	chmod +x ~/Desktop/Wine64_Explorer.desktop
	cp ~/Desktop/Wine64_Explorer.desktop /usr/share/applications/
	
Optional: Create desktop and menu shortcuts for winetricks gui:

    cd ~/Desktop
    echo '[Desktop Entry]
    Name=Winetricks32 Explorer
    Exec=bash -c "winetricks32 --gui"
    Icon=wine
    Type=Application' > ~/Desktop/Winetricks32_gui.desktop
	chmod +x ~/Desktop/Winetricks32_gui.desktop
	cp ~/Desktop/Winetricks32_gui.desktop /usr/share/applications/

    cd ~/Desktop
    echo '[Desktop Entry]
    Name=Winetricks64 Explorer
    Exec=bash -c "winetricks64 --gui"
    Icon=wine
    Type=Application' > ~/Desktop/Winetricks64_gui.desktop
	chmod +x ~/Desktop/Winetricks64_gui.desktop
	cp ~/Desktop/Winetricks64_gui.desktop /usr/share/applications/
	
## Example games 

### Portal Win32

Here's how you can run Portal game for Windows using Wine32 and Box86. Without hardware acceleration (GPU):

	cd /path/to/hl2.exe
    BOX86_NOBANNER=1 WINEDEBUG=-all wine hl2.exe -steam -game portal -silent -window -novid -applaunch 400 -dxlevel 80 -width 800 -height 600
	
It should run and working, but there's a bug with the light exposure, and everything slowly transform to white.

To solve the exposure bug, check [Install DXVK](Hardware_Acceleration_Resources.md#Install%20DXVK). It will not run accelerated inside proot, as the proot doesn't have access to Vulkan driver: 

    MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 BOX86_NOBANNER=1 WINEDEBUG=-all wine hl2.exe -steam -game portal -silent -window -novid -applaunch 400 -dxlevel 80 -width 800 -height 600
	
### Call Of Duty 2

Navigate to the game folder:

    cd /path/to/CoD2MP_s.exe

If you have DXVK as above, software rendering Direct3D through Vulkan:
 
    BOX86_NOBANNER=1 WINEDEBUG=-all wine CoD2MP_s.exe
	
It also works fine without DXVK, with software rendering.

Like above, I didn't manage to get hardware acceleration to work on the SD865, Adreno 650 GPU, proot with Wine for DirectX games. Lack of full OpenGL support of the VirGL client-server might be the cause of the errors.

### Euro Truck Simulator

Luckily, this game can run native with OpenGL, so we can play it with hardware acceleration:

    cd /path/to/eurotrucks.exe
	MESA_GL_VERSION_OVERRIDE=4.5COMPAT GALLIUM_DRIVER=virpipe BOX86_NOBANNER=1 WINEDEBUG=-all wine eurotrucks.exe
	
Note: I use the wine with the DXVK to start the game, as it crash otherwise, probably the launcher check for DirectX support, but it will run with plain OpenGL.

You can edit game configs using, e.g.: `nano ~/.wine32/drive_c/users/root/Documents/Euro\ Truck\ Simulator/config.cfg` after you run the game for the first time, if you need to override resolution manually, then you can launch `game.exe` directly. 
The game have a problem with the captured mouse. Use CTRL+ALT+DEL to release mouse, or open another GUI app window and use ALT+TAB.

Performance with software rendering: about 2 FPS.

With hardware acceleration, `virgl_test_server_android`, window, 1280 x 720, medium, the game is almost playable, ~ 20 FPS.

Using the Zink virgl server:

    MESA_NO_ERROR=1 GALLIUM_DRIVER=zink ZINK_DESCRIPTORS=lazy MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 virgl_test_server --use-egl-surfaceless --use-gles

And starting game with:

    MESA_GL_VERSION_OVERRIDE=4.3 GALLIUM_DRIVER=virpipe BOX86_NOBANNER=1 WINEDEBUG=-all wine game.exe
	
The performance difference is quite minimal.