#!/usr/bin/env bash

if [ "${#}" -lt 1 ]; then
  echo "Usage ${0} <task>" >&2
  exit 1
fi

set -ex

ansible-playbook -i inventory.ini --ask-become-pass "${@}"
