#!/usr/bin/env bats

set -euo pipefail

function setup {
  export BUILD="${BUILD:-build}"
  export TAG="$(cat "${BUILD}/docker.tag" | xargs echo -n)"
  export GNUPGHOME="${GNUPGHOME:-${HOME}/.gnupg}"

  [ -n "${PACKAGE:-}" ]
  [ -n "${VERSION:-}" ]
  [ -d "${GNUPGHOME}" ]
}

@test "01 - DEB package builds" {
  run docker run -it --rm \
    -e USER_UID="$(id -u)" \
		-e USER_GID="$(id -g)" \
    -v "`realpath ${GNUPGHOME}`:/gnupg:ro" \
    -v "`pwd`/${BUILD}:/app" \
    -w /app \
    "${TAG}" \
    "cd ${PACKAGE}_${VERSION} && dpkg-buildpackage -rfakeroot -b -uc"
  
  [ "$status" -eq 0 ]
  echo "$output" >&2
}

@test "02 - DEB package installs" {
  fname="${BUILD}/${PACKAGE}_${VERSION}_amd64.deb"

  run docker run -it --rm \
    -v "`pwd`/${fname}:/app/package.deb" \
    -w /app \
    ubuntu:bionic \
    /bin/bash -c 'apt-get update && apt-get install -y /app/package.deb && ${PACKAGE} --version | grep ${VERSION}'
}
