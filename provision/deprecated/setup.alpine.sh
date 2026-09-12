#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  _err "must run as root"
  exit 1
fi

RED='\e[0;31m'
GRN='\e[0;32m'
RST='\e[0m'

function _err() { echo -e "${RED}!ERR: $* ${RST}" >&2; }
function _info() { echo -e "${GRN}INFO: $* ${RST}"; }

DOTFILES="${HOME}/.dotfiles"

DEPS=(
  build-base
  cmake
  docker
  automake
  make
  autoconf
  libtool
  pkgconf
  coreutils
  curl
  unzip
  tmux
  stow
  docker
  git
  gettext  # gettext-tiny-dev
  ripgrep
  fzf
  xclip
  starship
  npm
  shellcheck
  rustup rustup-bash-completion rust-analyzer
)

_info "Installing core deps"
sudo apk update
sudo apk add "${DEPS[@]}"

_info "Setting-up dotfiles"
if [ ! -d "${DOTFILES}" ]; then
  git clone https://github.com/AlfredWilmot/dotfiles.git "${DOTFILES}"
  cd "${DOTFILES}" && stow .
else
  _err "'${DOTFILES}' already exists!"
fi

_info "Adding ${SUDO_USER} to the docker group"
addgroup "${SUDO_USER}" docker

_info "Configuring and enabling docker"
rc-update add docker boot
rc-update add containerd boot
service docker start
service containerd start

_info "Initialise rust"
rustup-init -y
