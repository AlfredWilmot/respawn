# Incus VM launch fails due to missing `required UEFI firmware files: []`

VM fails to start when I try to create a `test-vm` without secure-boot enabled:
```bash
incus launch images:debian/12 --vm test-vm
# Error: Failed instance creation: Couldn't find one of the required UEFI firmware files: []

incus info test-vm --show-log
# Name: test-vm
# Description:
# Status: STOPPED
# Type: virtual-machine
# Architecture: x86_64
# Created: 2025/08/11 13:45 BST
# Last Used: 1970/01/01 01:00 BST
# Error: open /var/log/incus/test-vm/qemu.log: no such file or directory

incus list
# +---------+---------+------+------+-----------------+-----------+
# |  NAME   |  STATE  | IPV4 | IPV6 |      TYPE       | SNAPSHOTS |
# +---------+---------+------+------+-----------------+-----------+
# | test-vm | STOPPED |      |      | VIRTUAL-MACHINE | 0         |
# +---------+---------+------+------+-----------------+-----------+
```

And subsequent attempts to start the created VM will result in the same error.

The solution to this problem was greatly helped by [this](https://discuss.linuxcontainers.org/t/attempting-to-launch-a-vm-fails-looking-for-empty-list-of-uefi-firmwares/22365/4).


# Context

Some information about the host and packages that are possible relevant:
```bash
# Alpine Linux v3.22

uname -mrsv
# Linux 6.12.41-0-lts #1-Alpine SMP PREEMPT_DYNAMIC 2025-08-07 06:15:54 x86_64

incus --version
# 6.0.4

qemu-system-x86_64 --version
# QEMU emulator version 10.0.0
# Copyright (c) 2003-2025 Fabrice Bellard and the QEMU Project developers
```

- snippet taken from `incus info`:
```yaml
  driver: qemu | lxc
  driver_version: 10.0.0 | 6.0.4
  firewall: xtables
  kernel: Linux
  kernel_architecture: x86_64
  kernel_features:
    idmapped_mounts: "true"
    netnsid_getifaddrs: "true"
    seccomp_listener: "true"
    seccomp_listener_continue: "true"
    uevent_injection: "true"
    unpriv_binfmt: "true"
    unpriv_fscaps: "true"
  kernel_version: 6.12.41-0-lts
  lxc_features:
    cgroup2: "true"
    core_scheduling: "true"
    devpts_fd: "true"
    idmapped_mounts_v2: "true"
    mount_injection_file: "true"
    network_gateway_device_route: "true"
    network_ipvlan: "true"
    network_l2proxy: "true"
    network_phys_macvlan_mtu: "true"
    network_veth_router: "true"
    pidfd: "true"
    seccomp_allow_deny_syntax: "true"
    seccomp_notify: "true"
    seccomp_proxy_send_notify_fd: "true"
  os_name: Alpine Linux
  os_version: 3.22.1
```

#  Solution(?)
VM successfully starts when passing `-c security.boot=false`:
```bash
incus launch images:debian/12 --vm test-vm -c security.secureboot=false
# Launching test-vm
```
An IP-address is soon assigned thereafter:
``` bash
incus list
# +---------+---------+------------------------+------+-----------------+-----------+
# |  NAME   |  STATE  |          IPV4          | IPV6 |      TYPE       | SNAPSHOTS |
# +---------+---------+------------------------+------+-----------------+-----------+
# | test-vm | RUNNING | 10.90.225.113 (enp5s0) |      | VIRTUAL-MACHINE | 0         |
# +---------+---------+------------------------+------+-----------------+-----------+
```

And the VM can be interacted with via incus commands as expected:
```bash
incus exec test-vm /bin/bash

'root@test-vm:' cat /etc/os-release
# PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
# NAME="Debian GNU/Linux"
# VERSION_ID="12"
# VERSION="12 (bookworm)"
# VERSION_CODENAME=bookworm
# ID=debian
# HOME_URL="https://www.debian.org/"
# SUPPORT_URL="https://www.debian.org/support"
# BUG_REPORT_URL="https://bugs.debian.org/"
```

---

# Continued

I think that because the ISO used by the `talos-vm` does not have the `incus-agent` running
on it, incus is unable to setup a route to the host automatically.

```bash
incus launch images:debian/12 --vm test-vm -c security.secureboot=false
incus list
```

```text
+----------+---------+-----------------------+------+-----------------+-----------+
|   NAME   |  STATE  |         IPV4          | IPV6 |      TYPE       | SNAPSHOTS |
+----------+---------+-----------------------+------+-----------------+-----------+
| talos-vm | RUNNING | 10.90.225.121 (eth0)  |      | VIRTUAL-MACHINE | 0         |
+----------+---------+-----------------------+------+-----------------+-----------+
| test-vm  | RUNNING | 10.90.225.52 (enp5s0) |      | VIRTUAL-MACHINE | 0         |
+----------+---------+-----------------------+------+-----------------+-----------+
```

```bash
incus info talos-vm
```

```text
Name: talos-vm
Description:
Status: RUNNING
Type: virtual-machine
Architecture: x86_64
PID: 10756
Created: 2025/08/11 15:14 BST
Last Used: 2025/08/11 15:20 BST
Started: 2025/08/11 15:20 BST

Resources:
  Processes: -1
  Network usage:
    eth0:
      Type: broadcast
      State: UP
      Host interface: tap28adb503
      MAC address: 10:66:6a:6b:37:a1
      MTU: 1500
      Bytes received: 5.92kB
      Bytes sent: 1.56kB
      Packets received: 78
      Packets sent: 4
      IP addresses:
        inet:  10.90.225.121/24 (global)
```

```bash
incus info test-vm
```

```text
Name: test-vm
Description:
Status: RUNNING
Type: virtual-machine
Architecture: x86_64
PID: 12203
Created: 2025/08/11 15:36 BST
Last Used: 2025/08/11 15:37 BST
Started: 2025/08/11 15:37 BST

Operating System:
  OS: Debian GNU/Linux
  OS Version: 12
  Kernel Version: 6.1.0-37-amd64
  Hostname: test-vm
  FQDN: localhost

Resources:
  Processes: 11
  CPU usage:
    CPU usage (in seconds): 3
  Memory usage:
    Memory (current): 234.42MiB
  Network usage:
    enp5s0:
      Type: broadcast
      State: UP
      Host interface: tap486c2366
      MAC address: 10:66:6a:9a:06:a2
      MTU: 1500
      Bytes received: 1.01kB
      Bytes sent: 2.77kB
      Packets received: 7
      Packets sent: 29
      IP addresses:
        inet:  10.90.225.52/24 (global)
        inet6: fe80::1266:6aff:fe9a:6a2/64 (link)
    lo:
      Type: loopback
      State: UP
      MTU: 65536
      Bytes received: 0B
      Bytes sent: 0B
      Packets received: 0
      Packets sent: 0
      IP addresses:
        inet:  127.0.0.1/8 (local)
        inet6: ::1/128 (local)
```

I installed `talosctl` using the [install script](https://www.talos.dev/v1.10/talos-guides/install/talosctl/#alternative-install)
(after reviewing the script, of course!).

Using the [vagrant + libvirt](https://www.talos.dev/v1.10/talos-guides/install/virtualized-platforms/vagrant-libvirt/#preparing-the-environment)
talos setup example as a reference:

```bash
talosctl -n 10.90.225.121 get disks --insecure
```

```text
rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing: dial tcp
10.90.225.121:50000: connect: no route to host"
```
