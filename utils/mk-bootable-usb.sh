#!/bin/bash
set -e

declare ISO_URL ISO_SHA256SUM ISO_PATH

function _usage_notes() {
cat << EOF 1>&2
Usage: ${0} -p ISO_PATH [-u ISO_URL | -s ISO_SHA256SUM]
Create a bootable USB from an ISO file.

  -p	path to ISO file
  -u  [optional] iso download url
  -s  [optional] the iso's expected sha256 checksum
  -t  [optional] the target block device
EOF
	return 1
}

while getopts "t:u:p:s:h" opt; do
    case "$opt" in
    u)  ISO_URL="${OPTARG}"
        ;;
    p)  ISO_PATH="${OPTARG}"
        ;;
    s)  ISO_SHA256SUM="${OPTARG}"
        ;;
		t)  TARGET="${OPTARG}"
				;;
		h|*)  _usage_notes
				exit 1
				;;
    esac
done

function _verify_valid_iso_file() {
	FILETYPE="$(file --mime-type -b "${1}")"
	if [[ "${FILETYPE}" != application/*iso* ]]; then
		echo "ERR: file is not an ISO: ${FILETYPE}" >&2
		return 1
	fi
}

if [ -f "${ISO_PATH}" ]; then
	_verify_valid_iso_file "${ISO_PATH}"
elif [[ "${ISO_URL}" && "${ISO_PATH}" ]]; then
  echo "Downloading ${ISO_PATH} from ${ISO_URL} ..."
	curl -sLo "${ISO_PATH}" "${ISO_URL}"
	_verify_valid_iso_file "${ISO_PATH}" || { rm "${ISO_PATH}"; exit 1; }
else
	_usage_notes
fi

if [ "${ISO_SHA256SUM}" ]; then
	printf "\n%s" "Comparing ISO against provided sha256sum hash, hold on... "
	if [[ "$ISO_SHA256SUM" != "$(sha256sum "${ISO_PATH}" | awk '{print $1}')" ]]; then
		echo 'ERR: ISO hash mismatch' >&2
		exit 1
	fi
  echo "Success!"
fi

if [ -z "${TARGET}" ]; then
  echo ""
  echo "Remove USB block device."
  read -rp "Press <ENTER> when done."
  echo "Insert USB block device..."
  echo ""
  TARGET="$(udevadm monitor --subsystem-match=block --property | grep -m 1 DEVNAME | awk -F '=' '{print $2}')"
fi

# ensure target is valid and intended
if [ ! -b "$TARGET" ]; then
  echo "ERR: Installation target '${TARGET}' must be a valid block device!" >&2
  exit 1
fi
read -rp "Selected '${TARGET}', continue? [y/n] " svar; [[ $svar =~ [Yy] ]] || exit 1

echo "Installing ${ISO_PATH} onto ${TARGET}..."
dd bs=4M if="${ISO_PATH}" of="${TARGET}" conv=fsync oflag=direct status=progress

echo "success!"
