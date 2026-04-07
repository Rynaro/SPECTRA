#!/usr/bin/env bash
# lib/detector_registry.sh — SPECTRA Detector Registry
# Registration and dispatch for project discovery detectors.
# Each detector module sources this file and calls register_detector.
#
# Interface contract for detectors (see lib/detectors/README.md):
#   detector functions receive no args; they echo detected values as CSV.
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

[[ -n "${_SPECTRA_DETECTOR_REGISTRY_LOADED:-}" ]] && return 0
readonly _SPECTRA_DETECTOR_REGISTRY_LOADED=1

declare -gA _DETECTOR_FNS=()       # "category:name" → function
declare -ga _DETECTOR_ORDER=()     # preserves insertion order

# ─── register_detector ────────────────────────────────────────────────────────
# register_detector <category> <name> <function>
# Categories: language, framework, test, build, ci, database, architecture, conventions
register_detector() {
  local category="$1" name="$2" fn="$3"
  local key="${category}:${name}"
  _DETECTOR_FNS["$key"]="$fn"
  _DETECTOR_ORDER+=("$key")
}

# ─── run_detectors ────────────────────────────────────────────────────────────
# run_detectors <category>
# Runs all detectors in the given category.
# Prints CSV of detected values (empty string if nothing found).
run_detectors() {
  local category="$1"
  local results="" key fn result
  for key in "${_DETECTOR_ORDER[@]}"; do
    [[ "$key" != "${category}:"* ]] && continue
    fn="${_DETECTOR_FNS[$key]}"
    result=$("$fn" 2>/dev/null) || true
    if [[ -n "$result" ]]; then
      results="${results:+${results}, }${result}"
    fi
  done
  echo "${results:-Not detected}"
}

# ─── run_all_detectors ────────────────────────────────────────────────────────
# Runs all registered detectors and populates global DETECTION_RESULTS.
# DETECTION_RESULTS is an associative array: category → CSV string.
declare -gA DETECTION_RESULTS=()
run_all_detectors() {
  local categories=(language framework test build ci database architecture conventions)
  local cat
  for cat in "${categories[@]}"; do
    DETECTION_RESULTS["$cat"]=$(run_detectors "$cat")
  done
}
