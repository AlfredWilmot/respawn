#!/usr/bin/env bash

set -e

. utils.sh

DOTFILES="${HOME}/.dotfiles"

DEPS=(
  build-base
  cmake
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
