#!/usr/bin/env bash

RED='\e[0;31m'
GRN='\e[0;32m'
RST='\e[0m'

function _err() { echo -e "${RED}!ERR: $* ${RST}" >&2; }
function _info() { echo -e "${GRN}INFO: $* ${RST}"; }
