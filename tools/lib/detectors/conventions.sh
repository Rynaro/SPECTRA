#!/usr/bin/env bash
# lib/detectors/conventions.sh — Convention File Detectors
# Detects existing LLM configuration and documentation convention files.
# Results inform the installer about potential conflicts and existing context.
#
# Bash 3.2-compatible: the previous CONVENTION_FILE_DETAILS associative
# array is replaced by an ordered key list (_CONVENTION_KEYS) plus one
# indirectly-named variable per key (_CONVENTION_LABEL_<sanitized>).
#
# SPECTRA v4.2.5 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

# Ordered list of file-paths that were detected present. Iteration over
# this drives the summary output.
_CONVENTION_KEYS=()

_convention_set() {
  local file="$1" label="$2"
  local k; k="$(_spectra_sanitize_key "$file")"
  eval "_CONVENTION_LABEL_${k}=\$label"
  _CONVENTION_KEYS+=("$file")
}

_convention_reset() {
  local key k
  # "${arr[@]+"${arr[@]}"}" guards against empty-array expansion under
  # `set -u` — required on bash 3.2 where `"${arr[@]}"` on an empty
  # (but assigned) array errors out.
  for key in "${_CONVENTION_KEYS[@]+"${_CONVENTION_KEYS[@]}"}"; do
    k="$(_spectra_sanitize_key "$key")"
    unset "_CONVENTION_LABEL_${k}"
  done
  _CONVENTION_KEYS=()
}

_convention_get() {
  local file="$1"
  local k; k="$(_spectra_sanitize_key "$file")"
  local varname="_CONVENTION_LABEL_${k}"
  echo "${!varname:-}"
}

detect_conventions_all() {
  _convention_reset
  local result=""

  local convention_files=(
    "CLAUDE.md:Claude config"
    "AGENTS.md:AGENTS config"
    ".cursorrules:Cursor rules"
    ".github/copilot-instructions.md:Copilot instructions"
    "ARCHITECTURE.md:Architecture docs"
    "spectra-conventions.md:SPECTRA conventions"
    "README.md:README"
  )

  local entry file label lines
  for entry in "${convention_files[@]}"; do
    file="${entry%%:*}"
    label="${entry##*:}"
    if [[ -f "${PROJECT_ROOT}/${file}" ]]; then
      lines=$(wc -l < "${PROJECT_ROOT}/${file}" 2>/dev/null | tr -d ' ')
      _convention_set "$file" "${label} (${lines} lines)"
      result="${result:+${result}, }${label}"
    fi
  done

  # .cursor/rules/*.mdc
  if [[ -d "${PROJECT_ROOT}/.cursor/rules" ]]; then
    local mdc_count
    mdc_count=$(find "${PROJECT_ROOT}/.cursor/rules" -name "*.mdc" 2>/dev/null | wc -l | tr -d ' ')
    if (( mdc_count > 0 )); then
      _convention_set ".cursor/rules" "Cursor rules (${mdc_count} .mdc files)"
      result="${result:+${result}, }Cursor rules"
    fi
  fi

  # docs/adr
  if [[ -d "${PROJECT_ROOT}/docs/adr" ]]; then
    local adr_count
    adr_count=$(find "${PROJECT_ROOT}/docs/adr" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    if (( adr_count > 0 )); then
      _convention_set "docs/adr" "ADRs (${adr_count} files)"
      result="${result:+${result}, }ADRs"
    fi
  fi

  echo "${result:-None}"
}

# Summary string for project profile (multi-line)
get_convention_summary() {
  local summary=""
  local file label
  for file in "${_CONVENTION_KEYS[@]+"${_CONVENTION_KEYS[@]}"}"; do
    label="$(_convention_get "$file")"
    summary="${summary}- **${file}**: ${label}\n"
  done
  echo -e "${summary:-None detected}"
}

register_detector "conventions" "all" "detect_conventions_all"
