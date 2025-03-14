# xv6

`xv6` is "a simple, Unix-like teaching operating system" inspired by `Unix V6`,
and was developed by the `Operating System Engineering` group at `MIT`.
See here for details: https://pdos.csail.mit.edu/6.1810/2024/xv6.html

## Notes
An archlinux VM is used as the build-host for the `xv6` OS.

### Preparing the build host

Create `Vagrantfile`:
```bash
vagrant init archlinux/archlinux
```

Update the generated `Vagrantfile` to provision the VM with the
[required build deps](https://pdos.csail.mit.edu/6.1810/2024/tools.html).

[Resync the OpenPGP keys to prevent signature errors](https://bbs.archlinux.org/viewtopic.php?id=289895)
due to the VM base image not beeing updated from the time it was created:
```bash
archlinux-keyring-wkd-sync
```
