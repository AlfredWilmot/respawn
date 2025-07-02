# Debugging the `libvirt` provider for `vagrant`

Here's a very straightforward guide for how to get set-up with [qemu](https://www.qemu.org/) virtual machines,
under the `KVM` hypervisor using the [libvirt](https://libvirt.org/) API as a "provider" under `vagrant`:
https://www.adaltas.com/en/2018/09/19/kvm-vagrant-archlinux/

Some challenges I encountered while using [virt-manager](https://virt-manager.org/) are documented below:

### Problem: `ModuleNotFoundError: No module named 'gi'`

ensure `python-gobject` is installed:
```bash
pacman -Ss python*-gobject*
# extra/python-gobject 3.52.3-3 [installed]
#     Python bindings for GLib/GObject/GIO/GTK
# extra/python-gobject-docs 3.52.3-3
#     Developer documentation for PyGObject
```

or else you'll see this cryptic error when running `virt-manager`:
```bash
virt-manager
# Traceback (most recent call last):
#   File "/usr/bin/virt-manager", line 6, in <module>
#     from virtManager import virtmanager
#   File "/usr/share/virt-manager/virtManager/virtmanager.py", li
# ne 13, in <module>
#     import gi
# ModuleNotFoundError: No module named 'gi'
```


> [!WARNING]
> if using [penv](https://github.com/pyenv/pyenv), you _must_ use your `system`
> python version when running `virt-manger` after installing `python-gobject`.
> This can be achieved by setting it as the `global` python runtime:
> ```bash
> pyenv global system
> ```

## Misc

```bash
# properly remove packages
sudo pacman -Rns <PKG>
```
