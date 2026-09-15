#!/usr/bin/env bash
# Format a blk device (e.g. a USB stick)
#
# References:
# (https://stackoverflow.com/a/59670820/22415851)

declare -i _WIPE_CYCLES=1

_TARGET="$1"
if [ ! -b "$_TARGET" ]; then
  echo "Select a valid block device" 1>&2
  lsblk
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "must run as root" 1>&2
  exit 1
fi

echo "Wiping '${_TARGET}'"
while [ "$_WIPE_CYCLES" -gt 0 ]; do
		((_WIPE_CYCLES-=1))
		dd if=/dev/urandom of="$_TARGET" bs=1M status=progress
done
mkfs.ext4 "$_TARGET"
