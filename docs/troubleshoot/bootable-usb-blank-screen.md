# Bootable-USB blank-screen
Loading hardware drivers during kernel boot can cause the attached monitor
to turn off. This occured to me recently when attempting to run an `Alpine 3.22` bootable USB;
and it looks like [similar problems](https://gitlab.alpinelinux.org/alpine/aports/-/issues/6723)
have happened in the past.

In my case, because I just wanted to run a bootable USB to install an OS,
I rectified this issue by updating the `linux` command in the GRUB config file
(which I accessed by pressing `e` in the GRUB menu during startup):
```text
linux   /boot/vmlinuz-lts nomodeset
```
The only arguments provided to the `linux` command are `BOOT_IMAGE`, which is a path to the location
of the Linux kernel image that will be booted, and the `nomodeset` paramter which disables
[Kernel Mode setting](https://wiki.archlinux.org/title/Kernel_mode_setting).

Booting with this GRUB config line as shown leaves the display resolution
and "depth" of my rather old monitor untouched by the boot process,
and hence enables the geriatric gizmo to eventually show me a login terminal.

All is well... for now!
