#!/usr/bin/env bash
set -e

cd $(dirname $(dirname ${0}))

source configs/builder

DEPS="configs/container.deps"

if [[ $* == *"-c"* ]]
then
  DEPS="${DEPS} configs/chromium.deps"
fi

PKGS="$(cat ${DEPS} | tr '\n' ',')"

[[ "${UID}" == "0" ]] || (echo "[ERROR] Root permissions required to build a rootfs." && exit 1)

which debootstrap 2>&1 >/dev/null || (echo "[ERROR] debootstrap is required to build a rootfs." && exit 1)

[[ -d tmp/rootfs ]] && rm -rf tmp/rootfs
mkdir -p tmp/rootfs
debootstrap --include="${PKGS}" "${DEBIAN_REL}" tmp/rootfs "${DEBIAN_MIRROR}"
cd tmp/rootfs

if [ -d ../../overlay ]
then
  cp -R ../../overlay/* .
fi

tar cpJf ../../images/rootfs.tar.xz --one-file-system .
cd ../..
rm -rf tmp
