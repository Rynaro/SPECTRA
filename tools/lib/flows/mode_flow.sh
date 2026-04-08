#!/usr/bin/env bash
# lib/flows/mode_flow.sh — Mode Selection Flow
# Lets the user choose between Agent mode and Skill mode.
# Sets global SELECTED_MODE after completion.
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

[[ -n "${_SPECTRA_MODE_FLOW_LOADED:-}" ]] && return 0
readonly _SPECTRA_MODE_FLOW_LOADED=1

run_mode_flow() {
  # Non-interactive fast-path
  if [[ -n "${SPECTRA_MODE:-}" ]]; then
    SELECTED_MODE="$SPECTRA_MODE"
    log_ok "Mode (from env): ${BOLD}${SELECTED_MODE}${NC}"
    return 0
  fi

  tui_section "Installation Mode"

  echo -e "  ${BOLD}How should SPECTRA live in your project?${NC}"
  echo ""
  echo -e "  ${CYAN}1${NC}. ${BOLD}Agent${NC}  — SPECTRA is a standalone planning agent you invoke explicitly."
  echo -e "     ${DIM}Best when: you want a dedicated @spectra-planner agent in your LLM tool.${NC}"
  echo -e "     ${DIM}Creates a single agent file with the full SPECTRA methodology embedded.${NC}"
  echo ""
  echo -e "  ${CYAN}2${NC}. ${BOLD}Skill${NC}  — SPECTRA is a skill/rule your LLM loads on demand."
  echo -e "     ${DIM}Best when: you prefer SPECTRA as a lightweight reference, not a separate agent.${NC}"
  echo -e "     ${DIM}Creates a skills directory with SKILL.md and reference files.${NC}"
  echo ""

  local selection
  tui_select selection "Choose installation mode:" \
    "Agent — dedicated planner agent" \
    "Skill — on-demand methodology reference"

  case "$selection" in
    Agent*) SELECTED_MODE="agent" ;;
    Skill*) SELECTED_MODE="skill" ;;
    *)
      log_error "Unrecognized mode selection: ${selection}"
      exit 1
      ;;
  esac

  log_ok "Mode selected: ${BOLD}${SELECTED_MODE}${NC}"
}
