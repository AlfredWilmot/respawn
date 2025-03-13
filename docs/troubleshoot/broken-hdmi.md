# Broken HDMI `ThinkPad X260`
This is a problem unique to my linux laptop when used with an older monitor ([PHILIPS 221P3](https://www.philips.com.eg/c-p/221P3LPYES_00/brilliance-led-monitor-with-powersensor#specs)). \
It seems to have broken following some kernel update last year, because it was working before.

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
