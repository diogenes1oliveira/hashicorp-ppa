#!/usr/bin/env bats

function setup {
  TMPDIR="${BATS_TMPDIR}/$(uuidgen)"
  mkdir -p "${TMPDIR}"
  echo "# TMPDIR = ${TMPDIR}" >&3
}

function teardown {
  rm -rf "${TMPDIR}"
}

@test 'downloads Terraform 0.12.24 successfully' {
  run ./hashicorp-download-release \
    --package terraform \
    --version 0.12.24 \
    --arch linux_amd64 \
    --output-dir "${TMPDIR}"
  
  [ "$status" -eq 0 ]
  "${TMPDIR}/terraform" --version | grep 0.12.24

  # Check for incomplete downloads
  head -c -1000 "${TMPDIR}/terraform" > "${TMPDIR}/terraform-cropped"
  mv "${TMPDIR}/terraform-cropped" "${TMPDIR}/terraform"

  run ./hashicorp-download-release \
    --package terraform \
    --version 0.12.24 \
    --arch linux_amd64 \
    --output-dir "${TMPDIR}"
  
  [ "$status" -eq 0 ]
  "${TMPDIR}/terraform" --version | grep 0.12.24
}
