#!/usr/bin/env sh

set -e

. utils.sh

if [ "$(id -u)" -ne 0 ]; then
  _err "must run as root"
  exit 1
fi

_info "Updating apk"
apk update && apk upgrade

_info "Installing Docker"
apk add docker

_info "Adding ${SUDO_USER} to the docker group"
addgroup "${SUDO_USER}" docker

_info "Configuring and enabling docker"
rc-update add docker boot
rc-update add containerd boot
service docker start
service containerd start
