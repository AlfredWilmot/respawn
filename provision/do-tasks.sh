#!/usr/bin/env bash

if [ "${#}" -lt 2 ]; then
  echo "Usage ${0} <hostname> <task>" >&2
  exit 1
fi

set -ex

ansible-playbook -i inventory.ini --limit "${@}"
