#!/usr/bin/env bash
# lib/core.sh — SPECTRA Core Module
# Shared constants, colors, utility functions, and the module loader.
# Source this file; do not execute directly.
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

# ─── Guard against double-sourcing ───────────────────────────────────────────
[[ -n "${_SPECTRA_CORE_LOADED:-}" ]] && return 0
readonly _SPECTRA_CORE_LOADED=1

# ─── Version ──────────────────────────────────────────────────────────────────
readonly SPECTRA_VERSION="4.9.1"
readonly SPECTRA_REPO="https://github.com/Rynaro/SPECTRA"

# ─── Colors (with fallback for non-interactive / no-color) ───────────────────
_setup_colors() {
  if [[ -t 1 && "${NO_COLOR:-}" != "1" ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    MAGENTA='\033[0;35m'
    BOLD='\033[1m'
    DIM='\033[2m'
    NC='\033[0m'
  else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; MAGENTA=''; BOLD=''; DIM=''; NC=''
  fi
}
_setup_colors

# ─── Box-drawing characters ───────────────────────────────────────────────────
readonly BOX_TL='╔' BOX_TR='╗' BOX_BL='╚' BOX_BR='╝'
readonly BOX_H='═' BOX_V='║'
readonly BOX_TL_THIN='┌' BOX_TR_THIN='┐' BOX_BL_THIN='└' BOX_BR_THIN='┘'
readonly BOX_H_THIN='─' BOX_V_THIN='│'
readonly BOX_DIV_L='├' BOX_DIV_R='┤' BOX_DIV_H='─'

# ─── Logging ─────────────────────────────────────────────────────────────────
log_info()  { echo -e "${BLUE}▸${NC} $*"; }
log_ok()    { echo -e "${GREEN}✓${NC} $*"; }
log_warn()  { echo -e "${YELLOW}⚠${NC} $*" >&2; }
log_error() { echo -e "${RED}✗${NC} $*" >&2; }
log_step()  { echo -e "${CYAN}→${NC} $*"; }
log_dim()   { echo -e "${DIM}  $*${NC}"; }

# ─── Runtime Checks ───────────────────────────────────────────────────────────
require_bash_version() {
  # SPECTRA tools run on bash 3.2+ (macOS default). Caller may request a
  # higher floor, but 3.2 is the tested minimum.
  local required_major="${1:-3}"
  local required_minor="${2:-2}"
  local actual_major="${BASH_VERSINFO[0]}"
  local actual_minor="${BASH_VERSINFO[1]}"
  if (( actual_major < required_major )) ||
     (( actual_major == required_major && actual_minor < required_minor )); then
    log_error "SPECTRA requires bash ${required_major}.${required_minor} or later (you have ${BASH_VERSION})."
    exit 1
  fi
}

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" &>/dev/null; then
    log_error "Required command not found: ${BOLD}${cmd}${NC}"
    exit 1
  fi
}

# ─── Module Loader ────────────────────────────────────────────────────────────
# load_modules <directory>
# Sources every *.sh file found in <directory>, in sorted order.
# Skips files named README* or *.md.
load_modules() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    log_warn "load_modules: directory not found: ${dir}"
    return 0
  fi
  local f
  for f in "$dir"/*.sh; do
    [[ -f "$f" ]] || continue
    # shellcheck source=/dev/null
    source "$f" || { log_error "Failed to source module: ${f}"; exit 1; }
  done
}

# ─── Utility ─────────────────────────────────────────────────────────────────
# Trim leading/trailing whitespace from a string
trim() {
  local s="$*"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  echo "$s"
}

# Map an arbitrary key to a bash-legal variable-name suffix.
# Used by the detector/vendor registries to build indirect variable names
# for their (associative-array-free) storage. Non-alphanumerics become
# underscores, making keys like "category:name" or "paths/like/this" safe.
_spectra_sanitize_key() {
  local k="$1"
  k="${k//[^a-zA-Z0-9_]/_}"
  echo "$k"
}

# Repeat a character N times
repeat_char() {
  local char="$1" count="$2"
  printf '%*s' "$count" '' | tr ' ' "$char"
}

# Terminal width (defaults to 80 if tput fails)
term_width() {
  local w
  w=$(tput cols 2>/dev/null) || w=80
  echo "$w"
}
