#!/usr/bin/env bash

# early exit on error
set -e

DEPS=(

  # applications
  vlc firefox flameshot peek neovim

  # fonts
  noto-fonts-emoji noto-fonts-cjk

  # cli-tools
  yq git pandoc shellcheck ripgrep fzf xclip

  # sysadmin
  shadow stow tmux man curl openssh

  # programming languages
  lua53
  rustup

  # audio/video
  autorandr
  pipewire pipewire-docs pipewire-alsa pipewire-pulse pipewire-jack wireplumber
  alsa-lib alsa-utils
  helvum

  # virtualisation
  vagrant
  docker docker-buildx docker-compose
)

info() {
  # prints the passed vars as a string in a visually striking way
  echo "# -------------------------------------------------------- #"
  echo "# $*"
  echo "# -------------------------------------------------------- #"
}

install_deps() {
  info "Installing dependencies"
  ( set -x; yes | pacman -Suy "${DEPS[@]}" )
  return 0
}

setup_docker() {
  info "Setting-up docker"
  (
    set -x
    # ensure docker daemon starts when system boots, and start the daemon now
    systemctl enable docker
    systemctl start docker

    # create the docker group, add user to it
    groupadd -f docker
    usermod -aG docker "${USER}"
  )
}

setup_rust() {
  info "Setting-up rust"
  ( set -x; rustup default stable )
  return 0
}

setup_nvim_ide() {
  info "Setting-up neovim"

  #Install packer plugin manager (https://github.com/wbthomason/packer.nvim)
  PACKER_REPO="https://github.com/wbthomason/packer.nvim"
  PACKER_DST="${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim"
  PACKER_DIR="$(dirname ${PACKER_DST})"
  (
    set -x
    if [ ! -d "${PACKER_DIR}" ]; then
      mkdir -p "${PACKER_DIR}"
      git clone --depth 1 "${PACKER_REPO}" "${PACKER_DST}"
    fi

    #Install the packer packages so nvim is all configured and ready to go!
    nvim -c PackerSync -c 'sleep 10' -c qa --headless 2> /dev/null
  )
  return 0
}

setup_audio_services() {
  (
    set -x
    systemctl --user enable --now pipewire.socket
    systemctl --user enable --now pipewire-pulse.socket
    systemctl --user enable --now wireplumber.service
  )
}
# https://wiki.archlinux.org/title/PipeWire
# https://github.com/mikeroyal/PipeWire-Guide

if [ "$(id -u)" -ne 0 ]; then
  echo >&2 "Permission Err: must run as root"
  exit
fi


install_deps
setup_docker
setup_rust
setup_nvim_ide
setup_audio_services

info 'Done!'

# ---------- #
# References #
# ---------- #
#
# IDE:
# > https://github.com/wbthomason/packer.nvim/issues/502
#
# Multimedia:
# > https://wiki.archlinux.org/title/PipeWire
# > https://wiki.archlinux.org/title/WirePlumber
#
# Keybinding:
# > https://wiki.archlinux.org/title/Xbindkeys
