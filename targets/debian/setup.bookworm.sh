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
  docker docker-compose
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

function install_nvim_ide() {
  NVIM_VER=0.9
  NVIM_DST="${HOME}/.local/bin/.neovim"

  info "neovim: Installing IDE..."

  # nvim deps
  sudo apt install -y gettext ripgrep fzf xclip
  (
    set -x

    # has the repo been cloned?
    if [ ! -d "${NVIM_DST}" ]; then
      git clone -b "release-${NVIM_VER}" https://github.com/neovim/neovim.git "${NVIM_DST}"
    fi

    # has the binary been built?
    if [ ! -f "${NVIM_DST}/../nvim" ]; then
      cd "${NVIM_DST}"
      make CMAKE_BUILD_TYPE=RelWithDebInfo
      sudo make install && mv build/bin/nvim ..
    fi
  )

  info "neovim: Installing Plugin-manager..."

  PACKER_REPO="https://github.com/wbthomason/packer.nvim"
  PACKER_DST="${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim"
  PACKER_DIR="$(dirname "${PACKER_DST}")"
  (
    set -x

    # has packer been installed?
    if [ ! -d "${PACKER_DIR}" ]; then
      mkdir -p "${PACKER_DIR}"
      git clone --depth 1 "${PACKER_REPO}" "${PACKER_DST}"

      #Install the packer packages so nvim is all configured and ready to go!
      nvim -c PackerSync -c 'sleep 10' -c qa --headless 2> /dev/null
    fi
  )
  return 0
}

function install_pyenv() {
  [ -z "${1}" ] && { echo "must specify a python version!"; exit 1; }

  PYTHON_VERSION="${1}"
  PYENV_DST="${HOME}/.pyenv"
  VIRTUALENV_PLUGIN_DST="${HOME}/.pyenv/plugins/pyenv-virtualenv"

  info "pyenv: Installing dependencies..."

  sudo apt update; sudo apt install -y build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl git \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
  (
    set -x
    if [ ! -d "${PYENV_DST}" ]; then
      git clone https://github.com/pyenv/pyenv.git "${PYENV_DST}"
      cd "${PYENV_DST}" && src/configure && make -C src
    fi

    if [ ! -d "${VIRTUALENV_PLUGIN_DST}" ]; then
      git clone https://github.com/pyenv/pyenv-virtualenv.git "${VIRTUALENV_PLUGIN_DST}"
    fi
  )

  # ensure the pyenv binary can be seen, configure the global python version
  export PYENV_ROOT="${HOME}/.pyenv"
  [[ -d "${PYENV_ROOT}/bin" ]] && export PATH="${PYENV_ROOT}/bin:${PATH}"

  info "pyenv: setting Python ${PYTHON_VERSION} as global..."

  # if the desired Python version is not global, install it and make it global
  if ! pyenv version | grep -q "${PYTHON_VERSION}"; then
    pyenv install "${PYTHON_VERSION}"
    pyenv global "${PYTHON_VERSION}"
  fi
}
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment

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
