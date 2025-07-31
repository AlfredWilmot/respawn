#!/usr/bin/env bash

if [[ ! "$1" =~ ^[-a-zA-Z0-9]+\.Dockerfile ]]; then
  cat <<EOF

  Build and tag the specified Dockerfile following some convention.
  Optional ARGS are passed to the underlying 'docker build' command.

  Usage: $0 some-kind-of.Dockerfile [ARGS]

EOF
  exit 1
fi

DOCKERFILE="${1}"
REPOSITORY="respawn"
TAG="$(echo "${DOCKERFILE}"| awk -F '.' '{print $1}')"
shift

set -x
docker build -t "${REPOSITORY}:${TAG}" -f "${DOCKERFILE}" "${@}" .
