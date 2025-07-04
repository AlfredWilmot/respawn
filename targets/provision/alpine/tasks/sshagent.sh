#!/usr/bin/env sh
# SETUP THE SSHAGENT WITH A PREEXISTING SSHKEY #

. ../utils.sh

KEY_PATH="${HOME}/.ssh/id_rsa"

_info "Killing any existing SSH Agents"
killall -q ssh-agent

eval "$(ssh-agent -s)"
_info "Created a new SSH agent, registering ${KEY_PATH}"
ssh-add "${KEY_PATH}"

# verify ssh access to GH
ssh -T git@github.com
