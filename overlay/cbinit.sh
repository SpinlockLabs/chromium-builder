#!/usr/bin/env bash
set -e

echo "127.0.0.1 $(hostname)" >> /etc/hosts

bash /chromium/src/build/install-build-deps.sh \
  --no-prompt \
  --no-syms \
  --no-nacl \
  --no-arm
git clone \
  https://chromium.googlesource.com/chromium/tools/depot_tools.git \
  /opt/depot_tools

echo 'export PATH="/opt/depot_tools:${PATH}"' > /etc/profile.d/depot_tools.sh
chmod +x /etc/profile.d/depot_tools.sh
