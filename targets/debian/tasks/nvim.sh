#!/usr/bin/env bash

set -ex

NVIM_VER=0.9
NVIM_DST="${HOME}/.local/bin/.neovim"
PACKER_REPO="https://github.com/wbthomason/packer.nvim"
PACKER_DST="${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim"
PACKER_DIR="$(dirname "${PACKER_DST}")"
NVIM_DEPS=(gettext ripgrep fzf xclip)

RED='\e[0;31m'
GRN='\e[0;32m'
RST='\e[0m'

function _err() { echo -e "${RED}!ERR: $* ${RST}" >&2; }
function _info() { echo -e "${GRN}INFO: $* ${RST}"; }


if [ "$(id -u)" -ne 0 ]; then
  _err "must run as root"
  exit 1
fi

# install deps
sudo apt install -y "${NVIM_DEPS[@]}"

# has the repo been cloned?
if [ ! -d "${NVIM_DST}" ]; then
  git clone -b "release-${NVIM_VER}" https://github.com/neovim/neovim.git "${NVIM_DST}"
fi

# has the binary been built?
if [ ! -f "${NVIM_DST}/../nvim" ]; then
  cd "${NVIM_DST}"
  _info "building neovim @ ${NVIM_VER}"
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install && mv build/bin/nvim ..
fi

# has packer been installed?
if [ ! -d "${PACKER_DIR}" ]; then
  _info "installing Packer to '${PACKER_DST}'"
  mkdir -p "${PACKER_DIR}"
  git clone --depth 1 "${PACKER_REPO}" "${PACKER_DST}"

  #Install the packer packages so nvim is all configured and ready to go!
  nvim -c PackerSync -c 'sleep 10' -c qa --headless 2> /dev/null
fi
