#!/usr/bin/env bash

# early exit on error
set -e

DEPS=(
  vlc
  firefox
  flameshot
  peek
  fzf
  git
  curl
  xclip
  man
  shellcheck
  autorandr
  tmux
  stow
  ripgrep
  neovim
  lua53
  yq
  noto-fonts-emoji
  noto-fonts-cjk
)

info() {
  # prints the passed vars as a string in a visually striking way
  echo "# -------------------------------------------------------- #"
  echo "# $*"
  echo "# -------------------------------------------------------- #"
}

install_deps() {
  info "Installing dependencies"
  set -x
  yes | sudo pacman -Suy "${DEPS[@]}"
  set +x
}

setup_nvim_ide() {
  info "Installing neovim..."

  #Install packer plugin manager (https://github.com/wbthomason/packer.nvim)
  PACKER_REPO="https://github.com/wbthomason/packer.nvim"
  PACKER_DST="${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim"
  PACKER_DIR="$(dirname ${PACKER_DST})"

  set -x
  if [ ! -d "${PACKER_DIR}" ]; then
    mkdir -p "${PACKER_DIR}"
    git clone --depth 1 "${PACKER_REPO}" "${PACKER_DST}"
  fi

  #Install the packer packages so nvim is all configured and ready to go!
  nvim -c PackerSync -c 'sleep 10' -c qa --headless 2> /dev/null
  set +x
  return 0

  # References #
  # > https://github.com/wbthomason/packer.nvim/issues/502
}

install_deps
setup_nvim_ide
echo "Done!"
