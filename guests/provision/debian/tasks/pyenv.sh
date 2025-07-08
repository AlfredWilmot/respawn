#!/usr/bin/env bash

set -e

. utils.sh

PYENV_DST="${HOME}/.pyenv"
VIRTUALENV_PLUGIN_DST="${HOME}/.pyenv/plugins/pyenv-virtualenv"

if [ "$(id -u)" -ne 0 ]; then
  _err "must run as root"
  exit 1
fi

[ -z "${1}" ] && { _err "must specify a python version!"; exit 1; }

PYTHON_VERSION="${1}"

_info "pyenv: Installing dependencies..."

sudo apt update && sudo apt install -y build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev curl git \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

if [ ! -d "${PYENV_DST}" ]; then
  git clone https://github.com/pyenv/pyenv.git "${PYENV_DST}"
  cd "${PYENV_DST}" && src/configure && make -C src
fi

if [ ! -d "${VIRTUALENV_PLUGIN_DST}" ]; then
  git clone https://github.com/pyenv/pyenv-virtualenv.git "${VIRTUALENV_PLUGIN_DST}"
fi

# ensure the pyenv binary can be seen, configure the global python version
export PYENV_ROOT="${HOME}/.pyenv"
[[ -d "${PYENV_ROOT}/bin" ]] && export PATH="${PYENV_ROOT}/bin:${PATH}"

_info "pyenv: setting Python ${PYTHON_VERSION} as global..."

# if the desired Python version is not global, install it and make it global
if ! pyenv version | grep -q "${PYTHON_VERSION}"; then
  pyenv install "${PYTHON_VERSION}"
  pyenv global "${PYTHON_VERSION}"
fi

exit 1

# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
