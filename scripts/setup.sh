#!/usr/bin/env bash
set -e

BASE="$(realpath $(dirname $(dirname ${0})))"
IMG="chromium-builder"

die() {
  echo "${*}"
  exit 1
}

if [ "${UID}" != "0" ]
then
  die "[ERROR] Root permissions are required to run this script."
fi

if [ -z "${1}" ]
then
  die "Usage: chromium-builder-setup <source directory>"
fi

SRCDIR="$(realpath ${1})"

if [ ! -f "${SRCDIR}/.gclient" ]
then
  die "[ERROR] ${SRCDIR}/.gclient does not exist, is the source directory a Chromium checkout?"
fi

if [ ! -f "${BASE}/images/rootfs.tar.xz" ]
then
  echo "[WARN] Base rootfs image does not exist. Building image..."
  ${SHELL} "${BASE}/scripts/mkrootfs.sh"
fi

if machinectl list-images | grep "^${IMG} " 2>&1 >/dev/null
then
  machinectl remove "${IMG}"
fi

machinectl import-tar "${BASE}/images/rootfs.tar.xz" ${IMG}

cat ${BASE}/configs/nspawn | sed 's|{SRCDIR}|'${SRCDIR}'|g' > /etc/systemd/nspawn/${IMG}.nspawn
systemd-nspawn -M ${IMG} \
  /bin/bash /cbinit.sh
