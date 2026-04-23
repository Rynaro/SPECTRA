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
#
# Non-interactive (CI / scripts):
#   SPECTRA_VENDOR=claude SPECTRA_MODE=skill SPECTRA_YES=1 bash tools/spectra-init.sh /path/to/project
#
# Supported vendors: claude, copilot, cursor
# Requirements: bash 3.2+ (macOS default supported), standard coreutils
#
# SPECTRA v4.2.5 — https://github.com/Rynaro/SPECTRA
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

# ─── Resolve project paths (after config.sh to avoid overwriting) ────────────
if [[ $# -ge 1 && -d "$1" ]]; then
  PROJECT_ROOT="$(cd "$1" && pwd)"
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
