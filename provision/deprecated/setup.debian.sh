#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  _err "must run as root"
  exit
fi

RED='\e[0;31m'
GRN='\e[0;32m'
RST='\e[0m'

function _err() { echo -e "${RED}!ERR: $* ${RST}" >&2; }
function _info() { echo -e "${GRN}INFO: $* ${RST}"; }

DOTFILES_DIR="${HOME}/.dotfiles"

DEPS=(
  yq jq git pandoc
  stow tmux man curl ssh npm
  cmake build-essential
  shellcheck
  lua5.3
  rust-all
  vagrant
  netcat-openbsd
)

_info "Installing core deps"
sudo apt-get update && sudo apt-get install -y "${DEPS[@]}"

_info "Setting-up dotfiles"
if [ ! -d "${DOTFILES_DIR}" ]; then
  git clone https://github.com/AlfredWilmot/dotfiles.git "${DOTFILES_DIR}"
  cd "${DOTFILES_DIR}" && stow --adopt . && git restore . # overwrite any existing dotfiles
else
  _err "'${DOTFILES}' already exists!"
fi

_info "extras: Installing Starship (shell prompt)"
curl -sS https://starship.rs/install.sh | sh -s -- --yes > /dev/null

_info "extras: Installing LSPs..."
sudo npm i -g bash-language-server > /dev/null

_info "Install Docker"
UNWANTED_PKGS=(docker.io docker-doc docker-compose podman-docker containerd runc)
sudo apt-get remove "${UNWANTED_PKGS[@]}"
which docker &> /dev/null  || curl -fsSL https://get.docker.com | sh


set +e # TODO: handle failure modes of steps under here more elegantly

_info "Ensure user is part of docker group"
sudo groupadd docker
sudo usermod -aG docker "${SUDO_USER}"
newgrp docker

_info "Enable docker services"
# ensure docker service is always on
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# https://docs.docker.com/engine/install/debian/
# https://docs.docker.com/engine/install/linux-postinstall/
