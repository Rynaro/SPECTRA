#!/usr/bin/env bash
# spectra-init.sh — SPECTRA Installer
#
# Interactive installer that detects your LLM tool, lets you choose
# Agent or Skill mode, and places SPECTRA methodology files in the
# correct vendor-specific locations.
#
# Usage:
#   bash tools/spectra-init.sh                    # from project root
#   bash tools/spectra-init.sh /path/to/project   # explicit path
#   bash tools/spectra-init.sh --fit-only         # lite: project fit only
#
# Modes:
#   Full install (default) — detect stack, pick vendor + mode, install
#     SPECTRA methodology into the vendor's native location (e.g.
#     .claude/skills/spectra-methodology/), AND generate
#     .spectra/setup/{project-profile,adaptation-prompt,spectra-conventions}.md.
#   Fit-only (--fit-only or SPECTRA_FIT_ONLY=1) — skip vendor install and
#     the vendor/mode prompts; only generate the .spectra/setup/* files.
#     This is what 'eidolons spectra fit' invokes because the SPECTRA
#     methodology is already installed via the eidolons flow — the user
#     just needs the per-project fit artefacts.
#
# Non-interactive (CI / scripts):
#   SPECTRA_VENDOR=claude SPECTRA_MODE=skill SPECTRA_YES=1 bash tools/spectra-init.sh /path/to/project
#
# Supported vendors: claude, copilot, cursor
# Requirements: bash 3.2+ (macOS default supported), standard coreutils
#
# SPECTRA v4.2.6 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

set -euo pipefail

# ─── Resolve SPECTRA_HOME ────────────────────────────────────────────────────
SPECTRA_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Bootstrap: load core first ───────────────────────────────────────────────
# shellcheck source=lib/core.sh
source "${SPECTRA_HOME}/lib/core.sh"

require_bash_version 3 2

# ─── Load all modules ─────────────────────────────────────────────────────────
source "${SPECTRA_HOME}/lib/config.sh"

# ─── Argument parsing ─────────────────────────────────────────────────────────
# Default: full install. --fit-only / SPECTRA_FIT_ONLY=1 → lite mode.
SPECTRA_FIT_ONLY="${SPECTRA_FIT_ONLY:-false}"
_project_arg=""
for _arg in "$@"; do
  case "$_arg" in
    --fit-only)            SPECTRA_FIT_ONLY="true" ;;
    -h|--help)
      sed -n '1,25p' "${BASH_SOURCE[0]}"
      exit 0
      ;;
    *)                     _project_arg="$_arg" ;;
  esac
done
export SPECTRA_FIT_ONLY

# ─── Resolve project paths (after config.sh to avoid overwriting) ────────────
if [[ -n "$_project_arg" && -d "$_project_arg" ]]; then
  PROJECT_ROOT="$(cd "$_project_arg" && pwd)"
else
  PROJECT_ROOT="$(pwd)"
fi
PROJECT_NAME="$(basename "$PROJECT_ROOT")"
source "${SPECTRA_HOME}/lib/tui.sh"
source "${SPECTRA_HOME}/lib/errors.sh"
source "${SPECTRA_HOME}/lib/vendor_registry.sh"
source "${SPECTRA_HOME}/lib/detector_registry.sh"
source "${SPECTRA_HOME}/lib/installer.sh"

load_modules "${SPECTRA_HOME}/lib/vendors"
load_modules "${SPECTRA_HOME}/lib/detectors"
load_modules "${SPECTRA_HOME}/lib/flows"

# ─── Register signal handlers ─────────────────────────────────────────────────
register_traps

# ─── Run ──────────────────────────────────────────────────────────────────────
run_main_flow
