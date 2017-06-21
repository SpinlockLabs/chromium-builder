#!/usr/bin/env bash
set -e

BASE="$(realpath ${0}/../..)"
IMG="chromium-builder"

function info() {
  echo "[INFO] ${*}"
}

function usage() {
  echo "Usage: chromium-builder-setup <source directory>"
  exit 1
}

function die() {
  echo "[ERROR] ${*}"
  exit 1
}

if [ "${UID}" != "0" ]
then
  die "Root permissions are required to run this script."
fi

if [ -z "${1}" ]
then
  usage
fi

SRCDIR="$(realpath ${1})"

if [ ! -f "${SRCDIR}/.gclient" ]
then
  die "${SRCDIR}/.gclient does not exist, is the source directory a Chromium checkout?"
fi

if [ ! -f "${BASE}/images/rootfs.txz" ]
then
  "${SHELL}" "${BASE}/scripts/pull-rootfs.sh"
fi

if machinectl list-images | grep "^${IMG} " >/dev/null 2>&1
then
  machinectl remove "${IMG}"
fi

machinectl import-tar "${BASE}/images/rootfs.txz" "${IMG}"

NSPAWN="/etc/systemd/nspawn/${IMG}.nspawn"
cat "${BASE}/configs/nspawn" | sed 's|{SRCDIR}|'${SRCDIR}'|g' > ${NSPAWN}
systemd-nspawn -M "${IMG}" \
  /bin/bash /cbinit.sh
