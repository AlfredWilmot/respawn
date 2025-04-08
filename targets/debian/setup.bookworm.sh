#!/usr/bin/env bash

set -e

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

function info() {
  # prints the passed vars as a string in a visually striking way
  echo "# -------------------------------------------------------- #"
  echo "# $*"
  echo "# -------------------------------------------------------- #"
}

function setup_dotfiles() {
  DOTFILES_DIR="${HOME}/dotfiles"
  (
    set -x
    if [ ! -d "${DOTFILES_DIR}" ]; then
      git clone https://github.com/AlfredWilmot/dotfiles.git "${DOTFILES_DIR}"
      cd "${DOTFILES_DIR}" && stow --adopt . && git restore . # overwrite any existing dotfiles
    fi
  )
}

function install_extras() {
  info "extras: Installing Starship (shell prompt)"
  curl -sS https://starship.rs/install.sh | sh -s -- --yes > /dev/null

  info "extras: Installing LSPs..."
  sudo npm i -g bash-language-server > /dev/null
}


sudo apt-get update && sudo apt-get install -y "${DEPS[@]}"
setup_dotfiles
install_nvim_ide
install_pyenv 3.12
install_extras
sudo ./tasks/docker.sh
sudo ./tasks/nvim.sh
sudo ./tasks/pyenv.sh
