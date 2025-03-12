#!/usr/bin/env bash

# early exit on error
set -e

DEPS=(

  # ------------ #
  # GUI/TUI Apps #
  # ------------ #
  vlc firefox flameshot peek neovim
  zathura zathura-pdf-mupdf

  # ----- #
  # fonts #
  # ----- #
  noto-fonts-emoji noto-fonts-cjk

  # --------- #
  # cli-tools #
  # --------- #

  # inpect and manipulate files
  yq jq git pandoc ripgrep

  # networking
  openbsd-netcat net-tools tcpdump networkmanager

  # -------- #
  # sysadmin #
  # -------- #
  shadow stow tmux man curl openssh npm
  fzf xclip

  # ----------------------------------- #
  # languages, LSPs, linters, debuggers #
  # ----------------------------------- #

  # c
  clang gdb

  # python
  ruff
  pyright

  # bash
  shellcheck
  bash-language-server

  # lua
  lua53
  lua-language-server
  love # love2d (https://love2d.org/)

  # rust
  rustup

  # ----- #
  # audio #
  # ----- #
  pipewire pipewire-docs pipewire-alsa pipewire-pulse pipewire-jack wireplumber
  alsa-lib alsa-utils

  # ------------- #
  # video capture #
  # ------------- #
  zvbi # required by vlc to detect and use video-capture devices (ie. devices located under '/dev/videox')

  # ------------- #
  # video display #
  # ------------- #
  autorandr

  # -------------- #
  # virtualisation #
  # -------------- #
  vagrant virtualbox virtualbox-guest-utils-nox virtualbox-host-modules-arch
  docker docker-buildx docker-compose

  # ----------- #
  # shel-prompt #
  # ----------- #
  starship
)

function info() {
  # prints the passed vars as a string in a visually striking way
  echo "# -------------------------------------------------------- #"
  echo "# $*"
  echo "# -------------------------------------------------------- #"
}

function install_deps() {
  info "Installing dependencies"
  ( set -x; yes | pacman -Suy --noconfirm "${DEPS[@]}" )
  return 0
}

function setup_docker() {
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

function setup_rust() {
  info "Setting-up rust"
  ( set -x; rustup default stable )
  return 0
}

function setup_nvim_ide() {
  info "Setting-up neovim"

  #Install packer plugin manager (https://github.com/wbthomason/packer.nvim)
  PACKER_REPO="https://github.com/wbthomason/packer.nvim"
  PACKER_DST="${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim"
  PACKER_DIR="$(dirname "${PACKER_DST}")"
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

function setup_audio_services() {
  info "Setting-up audio services"
  (
    set -x
    systemctl --machine="${SUDO_USER}@.host" --user enable --now pipewire.socket
    systemctl --machine="${SUDO_USER}@.host" --user enable --now pipewire-pulse.socket
    systemctl --machine="${SUDO_USER}@.host" --user enable --now wireplumber.service
  )
}
# https://wiki.archlinux.org/title/PipeWire
# https://github.com/mikeroyal/PipeWire-Guide

function setup_wifi() {
  (
    set -x
    NetworkManager enable
  )
}
# https://wiki.archlinux.org/title/NetworkManager

function setup_udev_rules() {
  (
    set -x

    # create rules for user to control backlight directly (user must be in 'video' group)
    local UDEV_RULES='/etc/udev/rules.d'
    local BACKLIGHT=(/sys/class/backlight/**/brightness)

cat <<EOF | tee "${UDEV_RULES}/backlight.rules"
RUN+="/bin/chgrp video ${BACKLIGHT[@]}"
RUN+="/bin/chmod 0664 ${BACKLIGHT[@]}"
EOF

  )
}
# https://unix.stackexchange.com/a/625266/611772
# https://bbs.archlinux.org/viewtopic.php?pid=1935565#p1935565
# https://superuser.com/a/1393488

function setup_aur_helper() {
  (
    PARU_DIR="${SUDO_HOME}/.local/bin/paru"
    set -x
    sudo pacman -S --needed base-devel
    if [ ! -d "${PARU_DIR}" ]; then
      mkdir -p "${PARU_DIR}"
      git clone https://aur.archlinux.org/paru.git "${PARU_DIR}"
    fi
    cd "${PARU_DIR}"
    su "nobody" -c "bash -c 'makepkg -si'"
  )
}
# https://github.com/Morganamilo/paru?tab=readme-ov-file#installation

if [ "$(id -u)" -ne 0 ]; then
  echo >&2 "Permission Err: must run as root"
  exit
fi

install_deps
setup_docker
setup_rust
setup_nvim_ide
setup_audio_services
setup_wifi
setup_udev_rules
#setup_aur_helper

info 'Done!'

# ---------- #
# References #
# ---------- #
#
# IDE:
# > https://github.com/wbthomason/packer.nvim/issues/502
#
# LSP debug:
# > https://www.reddit.com/r/neovim/comments/zninc5/comment/j0hacys/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
#
# Multimedia:
# > https://wiki.archlinux.org/title/PipeWire
# > https://wiki.archlinux.org/title/WirePlumber
#
# Keybinding:
# > https://wiki.archlinux.org/title/Xbindkeys
