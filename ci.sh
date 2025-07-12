#!/usr/bin/env bash

find . -name Vagrantfile -exec rubocop -A {} \;
