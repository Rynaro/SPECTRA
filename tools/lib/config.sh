#!/usr/bin/env bash
# lib/config.sh — SPECTRA User-Facing Configuration
# Centralizes output paths, defaults, and environment-variable overrides.
# Source this file after core.sh; do not execute directly.
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

[[ -n "${_SPECTRA_CONFIG_LOADED:-}" ]] && return 0
readonly _SPECTRA_CONFIG_LOADED=1

# ─── Output paths ─────────────────────────────────────────────────────────────
SPECTRA_DIR=".spectra"
SPECTRA_PLANS_DIR="${SPECTRA_DIR}/plans"
SPECTRA_SETUP_DIR="${SPECTRA_DIR}/setup"
PROFILE_OUT="${SPECTRA_SETUP_DIR}/project-profile.md"
PROMPT_OUT="${SPECTRA_SETUP_DIR}/adaptation-prompt.md"

# ─── Non-interactive overrides ────────────────────────────────────────────────
# These env vars allow fully automated (CI / scripted) installs.
# SPECTRA_VENDOR=claude|copilot|cursor   — skip vendor detection + selection
# SPECTRA_MODE=agent|skill               — skip mode selection
# SPECTRA_YES=1                          — auto-confirm all prompts
# NO_COLOR=1                             — disable ANSI colors

SPECTRA_VENDOR="${SPECTRA_VENDOR:-}"
SPECTRA_MODE="${SPECTRA_MODE:-}"
SPECTRA_YES="${SPECTRA_YES:-0}"

# ─── Internal state (populated at runtime) ───────────────────────────────────
PROJECT_ROOT=""
PROJECT_NAME=""
SELECTED_VENDOR=""
SELECTED_MODE=""
INSTALLED_FILES=()
