#!/usr/bin/env bash

set -ex -o pipefail

ansible-playbook -K tasks/nvim.yaml
