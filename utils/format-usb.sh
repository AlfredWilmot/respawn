#!/usr/bin/env bash

declare -i _WIPE_CYCLES=1

_TARGET="$1"
[ -b "$_TARGET" ] || { echo "Select a valid block device"; exit 1; }

if [ "$(id -u)" -ne 0 ]; then
  echo "must run as root" 1>&2
  exit 1
fi

echo "Wiping '${_TARGET}'"
while [ "$_WIPE_CYCLES" -gt 0 ]; do
		dd if=/dev/urandom of="$_TARGET" bs=1M status=progress
		((_WIPE_CYCLES-=1))
done
mkfs.ext4 "$_TARGET"
