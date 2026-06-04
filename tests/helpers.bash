#!/usr/bin/env bash
# tests/helpers.bash — shared test helpers for the SPECTRA bats suite

SPECTRA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SPECTRA_ROOT

# sha256_of <path>
sha256_of() {
  local f="$1"
  if command -v shasum &>/dev/null; then
    shasum -a 256 "$f" | awk '{print $1}'
  elif command -v sha256sum &>/dev/null; then
    sha256sum "$f" | awk '{print $1}'
  else
    echo "0000000000000000000000000000000000000000000000000000000000000000"
  fi
}

# run_install_into_tmpdir [extra args…]
# Runs install.sh --non-interactive --force --hosts none into a fresh temp dir.
# Sets INSTALL_TARGET to the target path and INSTALL_MANIFEST to the manifest path.
run_install_into_tmpdir() {
  INSTALL_DIR="$(mktemp -d)"
  INSTALL_TARGET="${INSTALL_DIR}/spectra"
  INSTALL_MANIFEST="${INSTALL_TARGET}/install.manifest.json"
  bash "${SPECTRA_ROOT}/install.sh" \
    --target "${INSTALL_TARGET}" \
    --non-interactive \
    --force \
    --hosts none \
    "$@"
}

# teardown_install
teardown_install() {
  [[ -n "${INSTALL_DIR:-}" && -d "${INSTALL_DIR}" ]] && rm -rf "${INSTALL_DIR}" || true
}
