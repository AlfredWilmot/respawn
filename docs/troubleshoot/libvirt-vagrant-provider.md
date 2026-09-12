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
> [source](https://stackoverflow.com/a/54114370/22415851)

### Problem: `Failed to connect socket to '/run/libvirt/virtlogd-sock': Connection refused (Libvirt::Error)`

```bash
# pull an alpine VM image that uses the "libvirt provider":
vagrant box add generic/alpine318 --provider libvirt

# create a fresh Vagrantfile using the pulled VM image:
vagrant init generic/alpine318

# attempt to bring-up the VM:
vagrant up --provider=libvirt
# ...
#/home/user/.vagrant.d/gems/3.4.4/gems/fog-libvirt-0.13.2/lib/fog/libvirt/requests/compute/vm_action.rb:7:in 'Libvirt::Domain#create': Call to virDomainCreate failed:
# Failed to connect socket to '/run/libvirt/virtlogd-sock': Connection refused (Libvirt::Error)
```

### Problem: `No Internet Conection with libvirt NAT`
The solution is outlined [here](https://bbs.archlinux.org/viewtopic.php?id=284664):
> setting `firewall_backend=iptables` in `/etc/libvirt/network.conf`

__NOTE__: you must restart the `libvirtd.service` before these changes can take effect.

## Misc

```bash
# properly remove packages
sudo pacman -Rns SOME_PKG_TO_REMOVE

# inspect libvirt components
journalctl -u libvirtd.service -f
journalctl -u libvirtd.socket -f

# restart libvirt components
systemctl restart libvirtd.service
systemctl restart libvirtd.socket
```

## Usage

Here is a `Vagrantfile` sample that leverages the `libvirt` backend:

```ruby
# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

# NOTE: no guests specified, this file serves purely as a reference for libvirt integration.

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

Vagrant.configure('2') do |config|
  # -------------------------------- #
  # COMMON STEPS REGARDLESS OF GUEST #
  # -------------------------------- #

  # Ensure the 'vagrant-libvirt' plugin is installed:
  config.vagrant.plugins = 'vagrant-libvirt'

  # indicate the preferred provider
  config.vm.provider 'libvirt'

  config.ssh.insert_key = false

  # guest resource allocation
  config.vm.provider 'libvirt' do |libvirt|
    libvirt.cpus = 2
    libvirt.numa_nodes = [{ cpus: '0-1', memory: 4096, memAccess: 'shared' }]
    libvirt.memorybacking :access, mode: 'shared'
  end

  # prefer a user-defined synced folder
  # (https://vagrant-libvirt.github.io/vagrant-libvirt/examples.html#synced-folders)
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder './share', '/home/vagrant/share', type: 'virtiofs'

  # forwarding perms to enable development work
  config.vm.provision 'file', source: '~/.gitconfig', destination: '${HOME}/.gitconfig'
  config.ssh.forward_agent = true

  # ------------------------------------- #
  # FOLLOW-UP STEPS FOR PARTICULAR GUESTS #
  # ------------------------------------- #

  # ...

end
```

## References

- [libvrit networking](https://wiki.libvirt.org/VirtualNetworking.html)

- [qemu driver for libvirt](https://libvirt.org/drvqemu.html):
> ```
> qemu:///system      /etc/libvirt/qemu.conf
> qemu:///session     $XDG_CONFIG_HOME/libvirt/qemu.conf
> qemu:///embed       $rootdir/etc/qemu.conf
> ```
> If `$XDG_CONFIG_HOME` is not set in the environment, it defaults to `$HOME/.config`.
> For the embed URI the $rootdir represents the specified root directory from the connection URI.
> Please note, that it is very likely that the only `qemu.conf` file that will exist after installing libvirt is the `/etc/libvirt/qemu.conf`,
> if users of the session daemon or the embed driver want to override a built in value,
> then they need to create the file before connecting to the respective URI.
