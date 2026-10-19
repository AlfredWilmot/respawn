#!/usr/bin/env bash

set -exo pipefail

EMAIL="${1}"

GPG_FINGERPRINT="$(gpg --list-keys --with-colons "${EMAIL}" | grep '^fpr' | head -n1 | cut -d: -f10)"
GPG_TIMESTAMP="$(gpg --list-keys --with-colons "${EMAIL}" | grep '^pub' | head -n1 | cut -d: -f7)"
GPG_KEYID="$(gpg --list-keys --with-colons "${EMAIL}" | grep '^pub' | head -n1 | cut -d: -f5)"
echo "-----------"
echo "FINGERPRINT: ${GPG_FINGERPRINT}"
echo "EXPIRYDATE:  $(date -d @"${GPG_TIMESTAMP}")"
echo "KEYID:       ${GPG_KEYID}"
echo "-----------"

# NOTES:
# - [convert timestamp to datetime](https://stackoverflow.com/a/2371288/22415851)
# - [managing gpg keys in ansible](https://oneuptime.com/blog/post/2026-02-21-ansible-manage-gpg-keys/view#managing-gpg-key-rotation)
# - [how to verify commits on GH](https://daily-dev-tips.com/posts/how-to-verify-your-commits-on-github/)
# - [safely clear misconfigured gpg.format in git config](https://stackoverflow.com/questions/73726815/git-commit-failed-couldnt-load-public-key#comment135267740_73816112)
