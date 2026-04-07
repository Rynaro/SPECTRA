#!/usr/bin/env bash
# lib/detectors/conventions.sh — Convention File Detectors
# Detects existing LLM configuration and documentation convention files.
# Results inform the installer about potential conflicts and existing context.
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

# CONVENTION_FILE_DETAILS: populated by detect_conventions_all, used by installer
declare -gA CONVENTION_FILE_DETAILS=()

detect_conventions_all() {
  CONVENTION_FILE_DETAILS=()
  local result=""

  local -a convention_files=(
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
      CONVENTION_FILE_DETAILS["$file"]="${label} (${lines} lines)"
      result="${result:+${result}, }${label}"
    fi
  done

  # .cursor/rules/*.mdc
  if [[ -d "${PROJECT_ROOT}/.cursor/rules" ]]; then
    local mdc_count
    mdc_count=$(find "${PROJECT_ROOT}/.cursor/rules" -name "*.mdc" 2>/dev/null | wc -l | tr -d ' ')
    if (( mdc_count > 0 )); then
      CONVENTION_FILE_DETAILS[".cursor/rules"]="Cursor rules (${mdc_count} .mdc files)"
      result="${result:+${result}, }Cursor rules"
    fi
  fi

  # docs/adr
  if [[ -d "${PROJECT_ROOT}/docs/adr" ]]; then
    local adr_count
    adr_count=$(find "${PROJECT_ROOT}/docs/adr" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    if (( adr_count > 0 )); then
      CONVENTION_FILE_DETAILS["docs/adr"]="ADRs (${adr_count} files)"
      result="${result:+${result}, }ADRs"
    fi
  fi

  echo "${result:-None}"
}

# Summary string for project profile (multi-line)
get_convention_summary() {
  local summary=""
  local file label
  for file in "${!CONVENTION_FILE_DETAILS[@]}"; do
    label="${CONVENTION_FILE_DETAILS[$file]}"
    summary="${summary}- **${file}**: ${label}\n"
  done
  echo -e "${summary:-None detected}"
}

register_detector "conventions" "all" "detect_conventions_all"
