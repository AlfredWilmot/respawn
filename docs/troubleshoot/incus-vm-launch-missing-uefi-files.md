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
