#!/usr/bin/env bash
#
# eidolons spectra fit — produce the project-fit artefacts under
# .spectra/setup/ (project-profile.md, adaptation-prompt.md,
# spectra-conventions.md stub). Runs SPECTRA's retrofit tool in
# --fit-only mode: stack detection + fit artefacts only. NO vendor
# install is performed — the SPECTRA methodology is already wired
# through the eidolons flow (.eidolons/spectra/ + .claude/skills/
# etc.), so re-running vendor_install would be redundant.
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

# Hand off to the existing tool in lite (fit-only) mode. Additional
# flags/env vars (SPECTRA_YES, positional project path) still work.
exec bash "${TOOL_DIR}/spectra-init.sh" --fit-only "$@"
