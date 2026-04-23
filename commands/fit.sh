#!/usr/bin/env bash
#
# eidolons spectra fit — run SPECTRA's RETROFIT tool against the current
# project, producing .spectra/setup/project-profile.md +
# adaptation-prompt.md + spectra-conventions.md stub.
#
# Invoked by the nexus CLI's generic per-Eidolon dispatcher
# (eidolons <eidolon> <sub>). cwd is the consumer project root.

set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# commands/fit.sh lives inside .eidolons/spectra/ — the actual tool is
# copied as a sibling at install time.
TOOL_DIR="$(cd "${SELF_DIR}/../tools" && pwd)"

if [[ ! -x "${TOOL_DIR}/spectra-init.sh" ]]; then
  echo "Error: SPECTRA retrofit tool not found at ${TOOL_DIR}/spectra-init.sh" >&2
  echo "Reinstall SPECTRA via 'eidolons sync --force'." >&2
  exit 1
fi

# Hand off to the existing tool. It handles all flags/env vars on its own
# (SPECTRA_VENDOR, SPECTRA_MODE, SPECTRA_YES, positional project path, etc.)
exec bash "${TOOL_DIR}/spectra-init.sh" "$@"
