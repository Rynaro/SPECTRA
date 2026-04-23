#!/usr/bin/env bash
# lib/detector_registry.sh — SPECTRA Detector Registry
# Registration and dispatch for project discovery detectors.
# Each detector module sources this file and calls register_detector.
#
# Interface contract for detectors (see lib/detectors/README.md):
#   detector functions receive no args; they echo detected values as CSV.
#
# Bash 3.2-compatible: no associative arrays. Function registry uses an
# ordered key list (_DETECTOR_ORDER) plus one indirectly-named variable
# per key (_DETECTOR_FN_<sanitized>). DETECTION_RESULTS was an associative
# array of 8 fixed categories → it's now 8 scalar globals readable by
# existing consumers as ${DETECTION_RESULT_LANGUAGE}, etc.
#
# SPECTRA v4.2.5 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

[[ -n "${_SPECTRA_DETECTOR_REGISTRY_LOADED:-}" ]] && return 0
readonly _SPECTRA_DETECTOR_REGISTRY_LOADED=1

# Preserves detector insertion order. Keys are of the form "category:name"
# (e.g. "language:python"). Iteration over this list drives dispatch.
_DETECTOR_ORDER=()

# Scalar detection-result globals, populated by run_all_detectors. Fixed
# category set — these are the 8 slots consumers reference by name.
DETECTION_RESULT_LANGUAGE=""
DETECTION_RESULT_FRAMEWORK=""
DETECTION_RESULT_TEST=""
DETECTION_RESULT_BUILD=""
DETECTION_RESULT_CI=""
DETECTION_RESULT_DATABASE=""
DETECTION_RESULT_ARCHITECTURE=""
DETECTION_RESULT_CONVENTIONS=""

# _spectra_sanitize_key is defined in lib/core.sh, which loads before this.

# ─── register_detector ────────────────────────────────────────────────────────
# register_detector <category> <name> <function>
# Categories: language, framework, test, build, ci, database, architecture, conventions
register_detector() {
  local category="$1" name="$2" fn="$3"
  local key="${category}:${name}"
  local vkey; vkey="$(_spectra_sanitize_key "$key")"
  # Dynamic assignment via eval — portable across bash 3.2+.
  eval "_DETECTOR_FN_${vkey}=\$fn"
  _DETECTOR_ORDER+=("$key")
}

# ─── _detector_fn ─────────────────────────────────────────────────────────────
# Internal lookup: returns (echoes) the function name for a given detector key.
_detector_fn() {
  local key="$1"
  local vkey; vkey="$(_spectra_sanitize_key "$key")"
  local varname="_DETECTOR_FN_${vkey}"
  # Indirect expansion — bash 3.0+.
  echo "${!varname:-}"
}

# ─── run_detectors ────────────────────────────────────────────────────────────
# run_detectors <category>
# Runs all detectors in the given category.
# Prints CSV of detected values (empty string if nothing found).
run_detectors() {
  local category="$1"
  local results="" key fn result
  # Guarded expansion for bash 3.2 + `set -u` (empty array would error).
  for key in "${_DETECTOR_ORDER[@]+"${_DETECTOR_ORDER[@]}"}"; do
    [[ "$key" != "${category}:"* ]] && continue
    fn="$(_detector_fn "$key")"
    [[ -z "$fn" ]] && continue
    result=$("$fn" 2>/dev/null) || true
    if [[ -n "$result" ]]; then
      results="${results:+${results}, }${result}"
    fi
  done
  echo "${results:-Not detected}"
}

# ─── run_all_detectors ────────────────────────────────────────────────────────
# Runs every registered detector and populates the scalar globals above.
# Category set is fixed — adding a new category requires a new scalar
# (update this function + the header declarations).
run_all_detectors() {
  DETECTION_RESULT_LANGUAGE="$(run_detectors language)"
  DETECTION_RESULT_FRAMEWORK="$(run_detectors framework)"
  DETECTION_RESULT_TEST="$(run_detectors test)"
  DETECTION_RESULT_BUILD="$(run_detectors build)"
  DETECTION_RESULT_CI="$(run_detectors ci)"
  DETECTION_RESULT_DATABASE="$(run_detectors database)"
  DETECTION_RESULT_ARCHITECTURE="$(run_detectors architecture)"
  DETECTION_RESULT_CONVENTIONS="$(run_detectors conventions)"
}
