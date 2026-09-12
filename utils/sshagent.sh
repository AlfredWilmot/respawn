#!/usr/bin/env sh
# SETUP THE SSHAGENT WITH A PREEXISTING SSHKEY #

KEY_PATH="${KEY_PATH:-${HOME}/.ssh/id_rsa}"  #NOTE: use KEY_PATH if already set in current env

echo "Killing any existing SSH Agents"
killall -q ssh-agent

eval "$(ssh-agent -s)"
echo "Created a new SSH agent, registering ${KEY_PATH}"
ssh-add "${KEY_PATH}"

# verify ssh access to GH
ssh -T git@github.com
