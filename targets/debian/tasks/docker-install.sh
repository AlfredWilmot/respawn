#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo >&2 "Permission Err: must run as root"
  exit
fi

# remove all conflicting packages
UNWANTED_PKGS=(docker.io docker-doc docker-compose podman-docker containerd runc)
sudo apt-get remove "${UNWANTED_PKGS[@]}"

# invoke the docker install script
curl -fsSL https://get.docker.com | sh

# ensure user can access the docker.socket
sudo groupadd docker
sudo usermod -aG docker "${SUDO_USER}"
newgrp docker

# ensure docker service is always on
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# https://docs.docker.com/engine/install/debian/
# https://docs.docker.com/engine/install/linux-postinstall/
