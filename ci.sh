#!/usr/bin/env bash

find . -name Vagrantfile -exec rubocop -A {} \;
find . -name "*.sh" -exec shellcheck {} \;
