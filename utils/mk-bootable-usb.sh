#!/bin/bash

if [[ "$#" -ne 1 ]]; then
	echo "Usage: ${0} [ --auto | PATH_TO_BLOCK_DEVICE ]"
	exit 1
fi

# ------------ #
# INPUT CHECKS #
# ------------ #

function _help() {
cat << EOF 1>&2
	Usage: ${0} TODO
EOF
}

function auto_detect_target() {
		echo "Remove USB block device."
		read -rp "Press <ENTER> when done."
		echo "Insert USB block device"
		TARGET="$(udevadm monitor --subsystem-match=block --property | grep -m 1 DEVNAME | awk -F '=' '{print $2}')"
}

function confirm_target() {
	# ensure target is valid and intended
	if [ ! -b "$TARGET" ]; then
		echo "ERR: Installation target '${TARGET}' must be a valid block device!" >&2
		exit 1
	fi
	read -rp "Selected '${TARGET}', continue? [y/n] " svar; [[ $svar =~ [Yy] ]] || exit 1
}

function install_target() {

	ISO="${1}"
	TARGET="${2}"

	echo "Installing ${ISO} onto ${TARGET}..."
	dd bs=4M if="${ISO}" of="${TARGET}" conv=fsync oflag=direct status=progress
}

function gather_iso() {
	# try to download the ISO if it does not exist
	if [ ! -f "$ISO" ]; then
		echo "${ISO} missing!"
		curl -L -o "${ISO}" "${DOWNLOAD_URL}"
	fi

}

function verify_iso() {

	ISO_PATH="${1}"
	ISO_SHA="${2}"

	# is it actually an ISO?
	FILETYPE="$(file --mime-type -b "${ISO_PATH}")"
	if [[ "${FILETYPE}" != application/*iso* ]]; then
		echo "ERR: file is not an ISO: ${FILETYPE}" >&2
		return 1
	fi

	# does it match the expected hash?
	echo "Comparing ISO against sha256sum hash, hold on..."
	if [[ "$ISO_SHA" != "$(sha256sum "${ISO_PATH}" | awk '{print $1}')" ]]; then
		echo 'ERR: ISO hash mismatch' >&2
		return 1
	fi
}

echo "success!"

# REFERENCES:
# > https://www.paulserban.eu/blog/snippet/creating-a-simple-command-line-interface-cli-tool-with-bash/
