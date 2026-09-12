# Broken HDMI `ThinkPad X260`
This is a problem unique to my linux laptop when used with an older monitor ([PHILIPS 221P3](https://www.philips.com.eg/c-p/221P3LPYES_00/brilliance-led-monitor-with-powersensor#specs)). \
It seems to have broken following some kernel update last year, because it was working before.

> [!IMPORTANT]
> After reviewing the [archlinux Xorg wiki page](https://wiki.archlinux.org/title/Xorg),
> I determined that my graphics card was an `Intel Skylake GT2`
> (`lspci -v -nn -d ::03xx`), which requires the `xf86-video-intel` driver.
>
> I noticed there were multiple "Device Dependent X (DDX)" drivers installed on my host machine
> (`pacman -Ss xf86-video`). So I manually removed them one-by-one, and reinstalled
> only the required `xf86-video-intel` DDX driver to mitigate any conflicts.
>
> After the install was done, I was met with the following output:
> ```text
> (1/1) installing xf86-video-intel                                                 [##############################################] 100%
> >>> This driver now uses DRI3 as the default Direct Rendering
>     Infrastructure. You can try falling back to DRI2 if you run
>     into trouble. To do so, save a file with the following
>     content as /etc/X11/xorg.conf.d/20-intel.conf :
>       Section "Device"
>         Identifier  "Intel Graphics"
>         Driver      "intel"
>         Option      "DRI" "2"             # DRI3 is now default
>         #Option      "AccelMethod"  "sna" # default
>         #Option      "AccelMethod"  "uxa" # fallback
>       EndSection
> Optional dependencies for xf86-video-intel
>     libxrandr: for intel-virtual-output [installed]
>     libxinerama: for intel-virtual-output [installed]
>     libxcursor: for intel-virtual-output [installed]
>     libxtst: for intel-virtual-output [installed]
>     libxss: for intel-virtual-output [installed]
> :: Running post-transaction hooks...
> (1/1) Arming ConditionNeedsUpdate...
> ```
> Given that the `Thinkpad X260` was [first realsed in 2016](https://en.wikipedia.org/wiki/ThinkPad_X_series),
> it seems like it might not be compatible with `DRI3`. So I saved the
> `/etc/X11/xorg.conf.d/20-intel.conf` file as suggested by the output to fallback to `DRI2`.
> After rebooting my laptop, docking it to a `Lenovo ThinkPad Ultra Dock`, and plugging my monitor
> to the dock via a DisplayPort cable, I was finally able to configure and usre my connected monitor via `xrandr`.
>
> **SUCCESS**!
> (_although the laptopt's HDMI port does in fact still seem to be broken :(_)


#### System Info
```bash
OS: Arch Linux x86_64
Host: 20F5S4BY00 (ThinkPad X260)
Kernel: Linux 6.13.4-arch1-1
Packages: 786 (pacman)
Shell: bash 5.2.37
Display (IVO04E5): 1366x768 @ 60 Hz in 12" [Built-in]
WM: i3 (X11)
Cursor: Adwaita
Terminal: st 0.9.2
Terminal Font: Liberation Mono (12pt)
CPU: Intel(R) Core(TM) i5-6300U (4) @ 3.00 GHz
GPU: Intel HD Graphics 520 @ 1.00 GHz [Integrated]
```

#### Symptoms
- cannot detect monitor using `xrandr` when monitor is connected to computer HDMI port,
only built-in monitor is available:
    ```bash
    $: xrandr --listmonitors
    Monitors: 1
     0: +*eDP-1 1366/276x768/155+0+0  eDP-1
    ```
- monitor displays a "no video input" message on screen when when connected to computer HDMI port via a DVI-to-HDMI adapter.

- Kernel ring-buffer output when plugging-in HDMI cable:
    ```bash
    $: sudo dmesg
    # <PLUG_IN_HDMI_CABLE_TO_MONITOR>
    EDID block 0 (tag 0x00) checksum is invalid, remainder is 32
    ```
- viewing info for available PCI display devices, and corresponding kernel driver/modules in use:
    ```bash
    $: lspci -k | grep -EA3 'VGA|3D|Display'
    00:02.0 VGA compatible controller: Intel Corporation Skylake GT2 [HD Graphics 520] (rev 07)
            Subsystem: Lenovo Device 504a
            Kernel driver in use: i915
            Kernel modules: i915
    ```

#### References
- [[i915 Skylake] HDMI output does not work with some adapters](https://bugs.freedesktop.org/show_bug.cgi?id=92685)
- [kernal patch to try](https://patchwork.freedesktop.org/patch/195306/)
- [how to apply linux kernel patches](https://docs.kernel.org/process/applying-patches.html)
- [Intel Graphics Arch Linux wiki](https://wiki.archlinux.org/title/Intel_graphics)
