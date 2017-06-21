#!/usr/bin/env bash
set -e

cd "$(dirname ${0})/.."

readonly IMG="spinlocklabs/chromium-builder-rootfs"
readonly TOKEN_URL="https://auth.docker.io/token"

if ! which jq > /dev/null
then
  echo "[ERROR] The command line tool 'jq' is required for this script to function."
  exit 1
fi

function get_token() {
  response=$(curl -s "${TOKEN_URL}?service=registry.docker.io&scope=repository:${IMG}:pull")
  echo ${response} | jq -r ".token"
}

readonly token="$(get_token)"
function make_request() {
  curl -sL -H "Authorization: Bearer ${token}" "https://index.docker.io/v2/${1}"
}

function make_dl_request() {
  wget --header="Authorization: Bearer ${token}" "https://index.docker.io/v2/${1}" -O "${2}"
}

blob=$(make_request "${IMG}/manifests/latest" | jq -r ".fsLayers[].blobSum")
count=$(echo ${blob} | wc -l)

if [[ ${count} != 1 ]]
then
  echo "[ERROR] Rootfs image consists of multiple blobs."
fi

out=$(mktemp)
mkdir -p images
make_dl_request "${IMG}/blobs/${blob}" "${out}"
tar zxf "${out}" -C images
rm "${out}"
