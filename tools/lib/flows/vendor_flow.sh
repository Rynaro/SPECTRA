#!/usr/bin/env bash
# lib/flows/vendor_flow.sh — Vendor Selection Flow
# Orchestrates auto-detection + TUI selection of the LLM vendor.
# Sets global SELECTED_VENDOR after completion.
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

[[ -n "${_SPECTRA_VENDOR_FLOW_LOADED:-}" ]] && return 0
readonly _SPECTRA_VENDOR_FLOW_LOADED=1

run_vendor_flow() {
  # Non-interactive fast-path via env var
  if [[ -n "${SPECTRA_VENDOR:-}" ]]; then
    SELECTED_VENDOR="$SPECTRA_VENDOR"
    log_ok "Vendor (from env): ${BOLD}${SELECTED_VENDOR}${NC}"
    return 0
  fi

  tui_section "LLM Tool Detection"

  tui_spinner_start "Detecting LLM tools in project..."
  detect_vendors
  tui_spinner_stop

  # bash 3.2-compatible: no mapfile — read line-by-line.
  local all_vendors=()
  while IFS= read -r _line; do
    all_vendors+=("$_line")
  done < <(list_vendors)

  if [[ ${#DETECTED_VENDORS[@]} -eq 0 ]]; then
    _vendor_flow_manual_select "${all_vendors[@]}"

  elif [[ ${#DETECTED_VENDORS[@]} -eq 1 ]]; then
    _vendor_flow_confirm_single "${DETECTED_VENDORS[0]}"

  else
    _vendor_flow_multiple_detected
  fi
}

# One vendor detected — confirm with user
_vendor_flow_confirm_single() {
  local detected="$1"
  local description
  description=$(vendor_describe "$detected")

  log_ok "Detected: ${BOLD}${description}${NC}"
  echo ""

  if tui_confirm "Use ${BOLD}${description}${NC} for this installation?"; then
    SELECTED_VENDOR="$detected"
  else
    local all_vendors=()
    local _line
    while IFS= read -r _line; do
      all_vendors+=("$_line")
    done < <(list_vendors)
    _vendor_flow_manual_select "${all_vendors[@]}"
  fi
}

# Multiple vendors detected — show only detected ones + "show all" option
_vendor_flow_multiple_detected() {
  log_info "Multiple LLM tools detected in this project."
  echo ""

  local options=()
  local name
  for name in "${DETECTED_VENDORS[@]}"; do
    options+=("$(vendor_describe "$name")  ${DIM}[detected]${NC}")
  done
  options+=("Show all supported vendors...")

  local selection
  tui_select selection "Which tool should SPECTRA be installed for?" "${options[@]}"

  if [[ "$selection" == "Show all supported vendors..."* ]]; then
    local all_vendors=()
    local _line
    while IFS= read -r _line; do
      all_vendors+=("$_line")
    done < <(list_vendors)
    _vendor_flow_manual_select "${all_vendors[@]}"
    return
  fi

  # Map selection back to vendor name
  local i
  for (( i=0; i<${#DETECTED_VENDORS[@]}; i++ )); do
    if [[ "$selection" == "$(vendor_describe "${DETECTED_VENDORS[$i]}")"* ]]; then
      SELECTED_VENDOR="${DETECTED_VENDORS[$i]}"
      break
    fi
  done
}

# No vendor detected (or user chose "show all") — full manual list
_vendor_flow_manual_select() {
  local all_vendors=("$@")

  if [[ ${#DETECTED_VENDORS[@]} -eq 0 ]]; then
    log_warn "No LLM tool configuration detected in this project."
    echo -e "  ${DIM}You can still install SPECTRA — select your tool below.${NC}"
    echo ""
  fi

  local options=()
  local name
  for name in "${all_vendors[@]}"; do
    options+=("$(vendor_describe "$name")")
  done

  local selection
  tui_select selection "Which LLM tool do you use?" "${options[@]}"

  # Map selection back to vendor name
  local i
  for (( i=0; i<${#all_vendors[@]}; i++ )); do
    if [[ "$selection" == "$(vendor_describe "${all_vendors[$i]}")"* ]]; then
      SELECTED_VENDOR="${all_vendors[$i]}"
      break
    fi
  done
}
