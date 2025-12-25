#!/usr/bin/env bash

IMG_REPO="respawn"

IMG_TAG="$1"
shift

# determine valid image names from available *.Dockerfiles
VALID_IMAGES=($(find . -iname "*.Dockerfile" | sed 's@^.*/\(.*\)\.Dockerfile@\1@'))

# does the first input arg match one of the valid image names?
# (https://stackoverflow.com/a/47541882/22415851)
if ! printf "%s\0" "${VALID_IMAGES[@]}" | grep -F -x -z -- "${IMG_TAG}"; then
  echo "Must specify valid image name [${VALID_IMAGES[*]}]"
  echo "Usage: $0 some_name.Dockerfile [optional docker args]" 1>&2
  exit 1
fi

# build image if unavailable
AVAILABLE_IMAGES=($(docker images --format '{{.Tag}}'))
if ! printf "%s\0" "${AVAILABLE_IMAGES[@]}" | grep -F -x -z -- "${IMG_TAG}"; then
  echo "Building image ${IMG_TAG}..."
  ./build.sh "${IMG_TAG}.Dockerfile"
fi


CMD="docker run --rm -it "

# TODO properly parse user input
# - first arg should be name of image (corresponding to prefix of "some_name.Dockerfile")

case "${IMG_TAG}" in
  "dump1090")
    # select connected RLT-STR USB-device
    USB_PATH="$(lsusb | grep 'RTL.*DVB-T' | awk '{print "/dev/bus/usb/"$2"/"$4}' | tr -d ':'| sed -n '1p')"
    if [ -z "${USB_PATH}" ]; then
      echo "RTL-STR USB-device not detected!" 1>&2
      exit 1
    fi
    CMD+="--device=${USB_PATH} "
    ;;
  *)
    # do nothing
    ;;
esac

CMD+="${IMG_REPO}:${IMG_TAG} ${*}"

echo "${CMD}"; eval "${CMD}"
