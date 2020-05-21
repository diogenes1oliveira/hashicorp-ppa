#!/usr/bin/env bash

set -euo pipefail

groupadd --gid "${USER_GID:-1000}" ubuntu
useradd --uid "${USER_UID:-1000}" --gid "${USER_GID:-1000}" --create-home ubuntu

if [ -d /gnupg ]; then
  cp -R /gnupg /root/.gnupg
fi

trap "! test -d /app || chown -R ubuntu:ubuntu /app" EXIT

bash -c "$@"
