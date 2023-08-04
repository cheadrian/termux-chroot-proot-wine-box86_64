
# Hardware Acceleration Resources

Here you can find some useful information that will help in your way to get GPU to work inside proot / chroot.

## Documentation

[From Box86](https://github.com/ptitSeb/box86): Most x86 Games need OpenGL, so on ARM platforms a solution like gl4es might be necessary. (Some ARM platforms only support OpenGL ES and/or their OpenGL implementation is dodgy. (see OpenGL on Android)).
Box86 already wrap Vulkan. If your system has a 32bits Vulkan driver, box86 will use it when needed. Profile 1.0, 1.1, 1.2 and 1.3, with some extensions, should be OK. DXVK, including the 2.0, works. Some Vulkan drivers DOES NOT support DXVK for now (wine DirectX -> Vulkan wrapper).
On Panfrost side, PanVK is a bit young and I haven't tested dxvk with it yet.
You can implement some of these features using [Addons_Menu.sh](Scripts/Addons_Menu.sh).

## Using hardware acceleration inside proot / chroot

Basically, if you want to use the Android renderer, you require an OpenGL server inside the Termux which will communicate with the proot or chroot.

Android GL/ES -> Termux VirGL renderer server -> proot / chroot virpipe MESA gallium driver. 

Check this comment for [how Zink works](https://www.reddit.com/r/termux/comments/wa6p4g/comment/ii6x5l2/?utm_source=reddit&utm_medium=web2x&context=3).

[Virtio-GPU Venus](https://docs.mesa3d.org/drivers/venus.html) helps you to serialize the Vulkan API, and that means you could expose the Android Vulkan implementation to the proot / chroot. While there's no working example yet, probably this is the most flexible solution for the future, as it will use the native Vulkan driver of device directly.

Android Vulkan -> Termux Virtio Vulkan Proxy -> proot / chroot with compatible MESA Venus driver.

It is also possible to access Vulkan driver or even GPU directly from chroot, so you can skip the virgl_test_server with chroot with a bit of work, but you should compile or install a compatible driver for your device. I can't help you with one fit for all, as Linux drivers can be quite different for every device. Start by searching "your GPU model + MESA driver" on a search engine, and then include keywords such as XDA, Reddit, KGSL, Zink, Termux etc. .

### Compare performance inside Termux

Here's the performance difference inside Termux (no proot /no chroot) using glmark2 from tur-repo.
I keep touching the screen to boost frequencies. Battery setting in performance mode. POCO F2 PRO -> SD865, Adreno 650, using Termux:X11.

Using llvmpipe, software rendering:

	DISPLAY=:0 glmark2 -b build
	
FPS: 116 Frame Time: 8.675 ms
	
Using zink with mesa-zink

    MESA_GL_VERSION_OVERRIDE=4.5COMPAT GALLIUM_DRIVER=zink ZINK_DESCRIPTORS=lazy ZINK_DEBUG=compact DISPLAY=:0 glmark2 -b build
	
FPS: 297 Frame Time: 3.369 ms

### Compare performance inside Proot

Inside proot multiple methods of rendering can be used. On POCO F2 PRO, here are the results:

Using llvmpipe, software rendering:

    glmark2 -b build
	
FPS: 144 FrameTime: 6.944 ms

Using VirGL through virpipe, Android GL/ES:

    MESA_GL_VERSION_OVERRIDE=4.5 GALLIUM_DRIVER=virpipe glmark2 -b build
	
FPS: 122 FrameTime: 8.197 ms

Using VirGL through virpipe with Termux Zink driver, Android Vulkan:

    MESA_GL_VERSION_OVERRIDE=4.5 GALLIUM_DRIVER=virpipe glmark2 -b build
	
FPS: 117 FrameTime: 8.547 ms

Using Zink over Turnip:

	MESA_GL_VERSION_OVERRIDE=4.5 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform MESA_VK_WSI_DEBUG=sw glmark2 -b build
	
FPS: 114 FrameTime: 8.772 ms

Different benchmarks:

Using Vulkan over Turnip:

	VK_INSTANCE_LAYERS='VK_LAYER_MESA_overlay' MESA_VK_WSI_DEBUG=sw vkcube
	
FPS: 240 FrameTime: 5.9 ms

Using llvmpipe, software rendering:
	
	glxgears
	
2074 frames in 5.0 seconds = 414.677 FPS

Using Zink over Turnip:

    MESA_GL_VERSION_OVERRIDE=4.5 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform MESA_VK_WSI_DEBUG=sw glxgears
	
1301 frames in 5.0 seconds = 260.002 FPS

Keep in mind, while performance difference is quite unexpected, as it decrease instead multiply by 2x, or more times using the direct driver calls, the compatibility with some packages can be better, and so the performance. We will see a better performance with time.

### MESA and VirGL renderer in Termux

You can install two versions of virglrenderer and Mesa in Termux, one that is compatible with the native Android GLES and another one also add Zink support over Android Vulkan.

    pkg install x11-repo
	pkg update
    pkg install virglrenderer-android
	
To start the virgl server, from [x11-repo](https://github.com/termux/termux-packages/tree/master/x11-packages), simply:

    virgl_test_server_android &
	
If you want to test the Zink version on your device, then add [tur-repo](https://github.com/termux-user-repository/tur) and:

	pkg install tur-repo
	pkg update
    pkg install mesa-zink virglrenderer-mesa-zink
	
To start the virgl server with Zink:

    MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink ZINK_DESCRIPTORS=lazy virgl_test_server --use-egl-surfaceless --use-gles &
		
Additionally, you might need to use one or all of these environment settings for both, tune according to your device, also consider to eliminate `--use-gles`:

    MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.2

On non-rooted, POCO F2 PRO, **inside proot**, I obtain the maximum performance with virgl_test_server_android, but **in Termux**, using Zink driver, the performance is even greater, so I think there is a problem with the Zink virgl compatibility.

### Turnip for Adreno KGSL

When you use Turnip you can access Adreno KGSL directly from the proot, so you don't need VirGL proxy anymore. While there's a clear advantage, performance is not there yet, but probably will be at a greater level in a decent ammount of time. Turnip user-space driver -> Adreno KGSL Kernel driver -> GPU.

You can get the compiled Mesa with Turnip from the [xDoge26 git](https://github.com/xDoge26/proot-setup/tree/main/Packages).

	dpkg -i mesa-vulkan-kgsl_*
	
To test if it is working, you can run vkcube, directly on Vulkan, or use Zink to emulate OpenGL over Vulkan:

    TU_DEBUG=noconform MESA_VK_WSI_DEBUG=sw vkcube
	MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform MESA_VK_WSI_DEBUG=sw glxgears
	
### Run with GPU

Now, inside your proot / chroot you can run GPU accelerated graphics using the virpipe:

    apt install -y mesa-utils
    GALLIUM_DRIVER=virpipe glxgears
	
You might need to use some additional OVERRIDE env variables, depending on your app, such as:

    MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.2

And even more:

    MESA_EXTENSION_OVERRIDE=GL_EXT_texture_compression_s3tc PAN_MESA_DEBUG=gl3 
	
If the version of MESA you've installed from the distro packages doesn't have virgl driver enabled, check below how you can compile MESA from source with it.

### Additional info

You can check for Vulkan information with:

    pkg install vulkan-tools
	DISPLAY=? vulkaninfo
	
Inside can check the same info inside chroot / proot, but using apt install.

[TURNIP](https://www.phoronix.com/news/Mesa-20.0-Turnip-Lima-Bits) - Adreno Vulkan driver

"Turnip is the open-source Vulkan driver for newer Qualcomm Adreno graphics hardware and is worked on by Google folks and others.". You can build MESA Turnip Vulkan driver for Adreno using "-D vulkan-drivers=freedreno". 

[mesa-zink](https://github.com/termux-user-repository/tur/blob/master/tur/mesa-zink/build.sh) package, described above, is compiled with Turnip enabled "-D vulkan-drivers=swrast,freedreno -Dfreedreno-kgsl=true".

Precompiled binaries for Turnip driver from other devices [can be found here](https://github.com/K11MCH1/AdrenoToolsDrivers/releases). 
"Turnip driver with Zink to have hardware acceleration and support of OpenGL 3.0". 

For rooted phones: [Magisk Turnip releases and build script](https://github.com/ilhan-athn7/freedreno_turnip-CI/releases).

[Mesa's Turnip Now Advertises Vulkan 1.3 Support](https://www.phoronix.com/news/Turnip-Does-Vulkan-1.3): "DXVK has begun requiring Vulkan 1.3 for Direct3D 9/10/11 atop Vulkan."

[Turnip Vulkan Driver Now Works With Zink For OpenGL 4.6, Approaching Vulkan 1.3](https://www.phoronix.com/news/Turnip-Vulkan-Adreno-July-2022)

[Turnip now exposes Vulkan 1.3](https://blogs.igalia.com/dpiliaiev/turnip-vulkan-1-3/)

**Others**

[twaik](https://github.com/termux/termux-packages/discussions/16508#discussioncomment-5771003): As I can see you can simply build needed GLES libraries and put them into some location inside termux. You can use LD_LIBRARY_PATH trick to force virgl_test_server_android use your libraries.

## Install DXVK

If you have a Vulkan compatible GPU, then you can use [DXVK](https://github.com/doitsujin/dxvk).

"DXVK is a free and open source project that translates Direct3D calls to Vulkan in Linux. Integrating with the Wine compatibility layer, DXVK allows you to use a Vulkan renderer in Direct3D (D3D9, D3D10 and D3D11) applications and games in Linux."

Inside chroot / proot with the Wine installed:

    apt install mesa-vulkan-drivers mesa-vulkan-drivers:armhf libvulkan1 libvulkan1:armhf
	wget https://github.com/doitsujin/dxvk/releases/download/v2.1/dxvk-2.1.tar.gz
	tar xvf dxvk-2.1.tar.gz
	cd dxvk-2.1
	cp x32/* ~/.wine32/drive_c/windows/system32
	cp x32/* ~/.wine64/drive_c/windows/system32
	cp x64/* ~/.wine64/drive_c/windows/syswow64
	wine winecfg
	wine64 winecfg
		
"Open winecfg and manually add DLL overrides for d3d11, d3d10core, dxgi, and d3d9."

Please note: if you don't have access to the Vulkan driver, it will run through software Vulkan driver, so no hardware acceleration.

You can enable FPS info by DXVK_HUD=1.

"In order to remove DXVK from a prefix, remove the DLLs and DLL overrides, and run wineboot -u to restore the original DLL files."

The most easy way to launch a game without DXVK, which, I repeat, it will run without GPU acceleration as long as you don't have direct access to the Android Vulkan driver, or through chroot, is to use another `WINEPREFIX=`. E.g.: `WINEPREFIX=~/.wine32_ndx box86 wine winecfg` then run your game / apps using `WINEPREFIX=~/.wine32_ndx box86 wine`.

## Compile GL4ES in proot

[GL4ES - The OpenGL driver for GLES Hardware](https://randomcoderorg.github.io/gl4es-port/COMPILE.html)

    cd ~
	git clone https://github.com/ptitSeb/gl4es
	cd gl4es
	apt install -y gcc build-essential cmake libx11-dev
	mkdir build; cd build; cmake -S ../../gl4es; make install
	
Now you can use it by adding to env:

    LD_LIBRARY_PATH="/usr/lib/gl4es/"
	
Example:

    LD_LIBRARY_PATH="/usr/lib/gl4es/" glmark2	

## Compiling MESA from source

This will compile MESA with VirGL driver enabled. Based on [Termux mesa package](https://github.com/termux/termux-packages/blob/master/packages/mesa/build.sh) build configs.

For proot Ubuntu:

    echo "deb-src [signed-by="/usr/share/keyrings/ubuntu-archive-keyring.gpg"] http://ports.ubuntu.com/ubuntu-ports jammy main restricted universe multiverse" >> /etc/apt/sources.list

For chroot Ubuntu:

	echo "deb-src http://ports.ubuntu.com/ubuntu-ports jammy main restricted universe multiverse" >> /etc/apt/sources.list

Load the new src and install necessary deps:

    apt update
    apt build-dep mesa 
    apt install git
    git clone https://github.com/Mesa3D/mesa --depth 1
    cd mesa
    meson build -Dgbm=enabled -Dopengl=true -Degl=enabled -Degl-native-platform=x11 -Dgles1=disabled -Dgles2=enabled -Ddri3=enabled -Dglx=dri -Dllvm=enabled -Dshared-llvm=disabled -Dplatforms=x11,wayland -Dgallium-drivers=swrast,virgl -Dvulkan-drivers=swrast -Dosmesa=true -Dglvnd=true -Dxmlconfig=disabled
    ninja -C build install

## Relevant links

- [MESA: Zink - Universal - Vulkan](https://docs.mesa3d.org/drivers/zink.html)
- [MESA: VirGL - Remote GPU acceleration](https://docs.mesa3d.org/drivers/virgl.html)
- [MESA: Panfrost - Mali-G52, Mali-G57](https://docs.mesa3d.org/drivers/panfrost.html)
- [MESA: Lima - Mali-4xx](https://docs.mesa3d.org/drivers/lima.html)
- [MESA: Freedreno GLES, GL - Adreno 2xx-6xx](https://docs.mesa3d.org/drivers/freedreno.html)
- [Exagear: Installing libraries, running VirGL (for Mali)](https://www.exagear.wiki/index.php?title=Installation_instructions#Installing_libraries,_running_VirGL(for_Mali))
- [Exagear: Turnip](https://www.exagear.wiki/index.php?title=Turnip)
- [Reddit: Hardware acceleration in proot](https://www.reddit.com/r/termux/comments/wa6p4g/hardware_acceleration_in_proot/)
- [XDA: Getting freedreno/turnip/mesa/vulkan driver on a Poco F3](https://forum.xda-developers.com/t/getting-freedreno-turnip-mesa-vulkan-driver-on-a-poco-f3.4323871/)
- [Gitlab: Mesa issues](https://gitlab.freedesktop.org/mesa/mesa/-/issues/8460)
- [Github: GPU Accel Termux](https://github.com/ThatMG393/gpu_accel_termux)
- [Github: Mesa-turnip-kgsl](https://github.com/Grima04/mesa-turnip-kgsl)
- [Github: Mesa](https://github.com/Heasterian/mesa)
- [Gitlab: Freedreno_kgsl](https://gitlab.freedesktop.org/Hazematman/mesa/-/tree/freedreno_kgsl)
- [Gitlab: Mesa merge request](https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/21570)