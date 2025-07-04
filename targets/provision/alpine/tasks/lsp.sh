#!/usr/bin/env bash

sudo apk update && sudo apk upgrade

# bash
sudo npm install --global bash-language-server
sudo apk add shellcheck

# python
sudo apk add --no-cache git bash build-base libffi-dev openssl-dev bzip2-dev zlib-dev xz-dev readline-dev sqlite-dev tk-dev
curl -fsSL https://pyenv.run | bash
sudo apk add py3-pip

# rust
sudo apk add rustup rustup-bash-completion rust-analyzer
rustup-init -y
