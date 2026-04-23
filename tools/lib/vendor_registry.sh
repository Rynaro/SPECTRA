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
# Bash 3.2-compatible: no associative arrays. Vendor records are held as
# indirect vars (_VENDOR_DETECT_FN_<name>, _VENDOR_INSTALL_FN_<name>,
# _VENDOR_DESCRIBE_FN_<name>) plus an ordered key list (_VENDOR_ORDER).
#
# SPECTRA v4.2.5 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

[[ -n "${_SPECTRA_VENDOR_REGISTRY_LOADED:-}" ]] && return 0
readonly _SPECTRA_VENDOR_REGISTRY_LOADED=1

# Ordered vendor keys — drives dispatch and listing.
_VENDOR_ORDER=()

# Detected vendors, populated by detect_vendors.
DETECTED_VENDORS=()

# ─── register_vendor ──────────────────────────────────────────────────────────
# register_vendor <name> <detect_fn> <install_fn> <describe_fn>
register_vendor() {
  local name="$1" detect_fn="$2" install_fn="$3" describe_fn="$4"
  local vkey; vkey="$(_spectra_sanitize_key "$name")"
  eval "_VENDOR_DETECT_FN_${vkey}=\$detect_fn"
  eval "_VENDOR_INSTALL_FN_${vkey}=\$install_fn"
  eval "_VENDOR_DESCRIBE_FN_${vkey}=\$describe_fn"
  _VENDOR_ORDER+=("$name")
}

# ─── Internal lookups ────────────────────────────────────────────────────────
_vendor_detect_fn()   { local v; v="_VENDOR_DETECT_FN_$(_spectra_sanitize_key "$1")";   echo "${!v:-}"; }
_vendor_install_fn()  { local v; v="_VENDOR_INSTALL_FN_$(_spectra_sanitize_key "$1")";  echo "${!v:-}"; }
_vendor_describe_fn() { local v; v="_VENDOR_DESCRIBE_FN_$(_spectra_sanitize_key "$1")"; echo "${!v:-}"; }

# ─── detect_vendors ───────────────────────────────────────────────────────────
# Runs all registered detection functions.
# Populates global DETECTED_VENDORS array.
detect_vendors() {
  DETECTED_VENDORS=()
  local name fn
  # Guarded expansion for bash 3.2 + `set -u` (empty array would error).
  for name in "${_VENDOR_ORDER[@]+"${_VENDOR_ORDER[@]}"}"; do
    fn="$(_vendor_detect_fn "$name")"
    [[ -z "$fn" ]] && continue
    if "$fn" 2>/dev/null; then
      DETECTED_VENDORS+=("$name")
    fi
  done
}

# ─── list_vendors ─────────────────────────────────────────────────────────────
# Prints all registered vendor names, one per line.
list_vendors() {
  local name
  for name in "${_VENDOR_ORDER[@]+"${_VENDOR_ORDER[@]}"}"; do
    echo "$name"
  done
}

# ─── vendor_describe ──────────────────────────────────────────────────────────
# vendor_describe <name>  → calls that vendor's describe function
vendor_describe() {
  local name="$1"
  local fn; fn="$(_vendor_describe_fn "$name")"
  [[ -n "$fn" ]] && "$fn"
}

# ─── vendor_install ───────────────────────────────────────────────────────────
# vendor_install <name> <mode>  → calls that vendor's install function
vendor_install() {
  local name="$1" mode="$2"
  local fn; fn="$(_vendor_install_fn "$name")"
  if [[ -z "$fn" ]]; then
    log_error "No install function registered for vendor: ${name}"
    return 1
  fi
  "$fn" "$mode"
}
