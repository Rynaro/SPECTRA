#!/usr/bin/env bash
# lib/vendor_registry.sh — SPECTRA Vendor Registry
# Registration and dispatch for LLM vendor adapters.
# Each vendor adapter sources this file and calls register_vendor.
#
# Interface contract for adapters (see lib/vendors/README.md):
#   vendor_<name>_detect()     → exits 0 if detected, 1 if not
#   vendor_<name>_describe()   → prints a one-line human description
#   vendor_<name>_install()    → installs files; receives mode ("agent"|"skill")
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

[[ -n "${_SPECTRA_VENDOR_REGISTRY_LOADED:-}" ]] && return 0
readonly _SPECTRA_VENDOR_REGISTRY_LOADED=1

# Associative arrays require bash 4+
declare -gA _VENDOR_DETECT_FNS=()
declare -gA _VENDOR_INSTALL_FNS=()
declare -gA _VENDOR_DESCRIBE_FNS=()
declare -ga _VENDOR_ORDER=()   # preserves insertion order

# ─── register_vendor ──────────────────────────────────────────────────────────
# register_vendor <name> <detect_fn> <install_fn> <describe_fn>
register_vendor() {
  local name="$1" detect_fn="$2" install_fn="$3" describe_fn="$4"
  _VENDOR_DETECT_FNS["$name"]="$detect_fn"
  _VENDOR_INSTALL_FNS["$name"]="$install_fn"
  _VENDOR_DESCRIBE_FNS["$name"]="$describe_fn"
  _VENDOR_ORDER+=("$name")
}

# ─── detect_vendors ───────────────────────────────────────────────────────────
# Runs all registered detection functions.
# Populates global DETECTED_VENDORS array.
declare -ga DETECTED_VENDORS=()
detect_vendors() {
  DETECTED_VENDORS=()
  local name
  for name in "${_VENDOR_ORDER[@]}"; do
    local fn="${_VENDOR_DETECT_FNS[$name]}"
    if "$fn" 2>/dev/null; then
      DETECTED_VENDORS+=("$name")
    fi
  done
}

# ─── list_vendors ─────────────────────────────────────────────────────────────
# Prints all registered vendor names, one per line.
list_vendors() {
  local name
  for name in "${_VENDOR_ORDER[@]}"; do
    echo "$name"
  done
}

# ─── vendor_describe ──────────────────────────────────────────────────────────
# vendor_describe <name>  → calls that vendor's describe function
vendor_describe() {
  local name="$1"
  local fn="${_VENDOR_DESCRIBE_FNS[$name]:-}"
  [[ -n "$fn" ]] && "$fn"
}

# ─── vendor_install ───────────────────────────────────────────────────────────
# vendor_install <name> <mode>  → calls that vendor's install function
vendor_install() {
  local name="$1" mode="$2"
  local fn="${_VENDOR_INSTALL_FNS[$name]:-}"
  if [[ -z "$fn" ]]; then
    log_error "No install function registered for vendor: ${name}"
    return 1
  fi
  "$fn" "$mode"
}
