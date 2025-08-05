# Utils

Utilities to help with various sysadmin tasks.


### `mk-bootable-usb.sh`
```bash
# Usage docs:
$: ./mk-bootable-usb.sh
# Usage: ./mk-bootable-usb.sh -p ISO_PATH [-u ISO_URL | -s ISO_SHA256SUM]
# Create a bootable USB from an ISO file.
#
#   -p  path to ISO file
#   -u  [optional] iso download url
#   -s  [optional] the iso's expected sha256 checksum
#   -t  [optional] the target block device
```

```bash
# Example usage:
./mk-bootable-usb.sh \
    -p alpine-standard-3.22.1-x86_64.iso \
    -u https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/x86_64/alpine-standard-3.22.1-x86_64.iso \
    -s 96d1b44ea1b8a5a884f193526d92edb4676054e9fa903ad2f016441a0fe13089
```
