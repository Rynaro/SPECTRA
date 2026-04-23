#!/usr/bin/env bash
# lib/errors.sh — SPECTRA Error Handling & Cleanup
# Centralizes trap registration, rollback logic, and interrupt handling.
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

[[ -n "${_SPECTRA_ERRORS_LOADED:-}" ]] && return 0
readonly _SPECTRA_ERRORS_LOADED=1

# Track files/dirs created during installation for rollback. Bash 3.2
# doesn't support `declare -g`; since this file is sourced at top level
# (not inside a function), a plain global assignment is enough.
_CREATED_PATHS=()

track_created() {
  _CREATED_PATHS+=("$1")
}

# ─── Rollback ─────────────────────────────────────────────────────────────────
_rollback() {
  tui_spinner_stop 2>/dev/null || true
  if [[ ${#_CREATED_PATHS[@]} -gt 0 ]]; then
    echo ""
    log_warn "Rolling back partially installed files..."
    local p
    for p in "${_CREATED_PATHS[@]}"; do
      if [[ -e "$p" ]]; then
        rm -rf "$p"
        log_dim "Removed: ${p}"
      fi
    done
  fi
}

# ─── Interrupt handler ────────────────────────────────────────────────────────
_on_interrupt() {
  echo ""
  echo ""
  log_warn "Installation interrupted by user (Ctrl+C)."
  _rollback
  echo ""
  log_dim "No changes were made to your project."
  echo ""
  exit 130
}

# ─── Error handler ────────────────────────────────────────────────────────────
_on_error() {
  local exit_code=$?
  local line="${1:-unknown}"
  tui_spinner_stop 2>/dev/null || true
  echo ""
  log_error "Unexpected error at line ${line} (exit code: ${exit_code})."
  _rollback
  echo ""
  log_dim "If this is a bug, please report it at: ${SPECTRA_REPO}/issues"
  echo ""
  exit "$exit_code"
}

# ─── Register traps ───────────────────────────────────────────────────────────
register_traps() {
  trap '_on_interrupt' INT TERM
  trap '_on_error $LINENO' ERR
}

# ─── Permission check ─────────────────────────────────────────────────────────
check_write_permission() {
  local dir="$1"
  if [[ ! -w "$dir" ]]; then
    log_error "No write permission for: ${dir}"
    echo -e "  ${DIM}Try running with appropriate permissions, or change the target directory.${NC}"
    exit 1
  fi
}
