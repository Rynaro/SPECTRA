#!/usr/bin/env bash
# lib/flows/main_flow.sh — Main Installation Orchestrator
# Drives the complete SPECTRA installation experience from welcome to summary.
#
# Flow:
#   1. Welcome header
#   2. Project discovery (all detectors)
#   3. Project profile confirmation
#   4. Vendor detection + selection
#   5. Mode selection
#   6. Installation plan preview + confirm
#   7. Execute installation
#   8. Summary and next steps
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

[[ -n "${_SPECTRA_MAIN_FLOW_LOADED:-}" ]] && return 0
readonly _SPECTRA_MAIN_FLOW_LOADED=1

run_main_flow() {
  local start_time=$SECONDS

  # Step 1: Welcome
  tui_header "Intelligent Planning for AI-Assisted Development"
  echo -e "  ${DIM}Installing SPECTRA into: ${BOLD}${PROJECT_ROOT}${NC}"
  echo ""

  # Step 2: Project discovery
  tui_section "Project Discovery"
  tui_spinner_start "Analyzing project structure..."
  run_all_detectors
  detect_conventions_all 2>/dev/null || true
  tui_spinner_stop
  log_ok "Project analysis complete"
  echo ""

  # Step 3: Project profile preview
  _show_project_summary

  # Step 4: Vendor detection + selection
  run_vendor_flow

  # Step 5: Mode selection
  run_mode_flow

  # Step 6: Installation plan preview + confirm
  _show_install_plan

  # Step 7: Execute
  run_installer

  # Step 8: Summary
  local elapsed=$(( SECONDS - start_time ))
  run_summary_flow
  echo -e "  ${DIM}Completed in ${elapsed}s${NC}"
  echo ""
}

# ─── Project summary (preview before install) ─────────────────────────────────
_show_project_summary() {
  tui_summary "Project: ${PROJECT_NAME}" \
    "Languages"     "${DETECTION_RESULTS[language]:-Unknown}" \
    "Frameworks"    "${DETECTION_RESULTS[framework]:-Not detected}" \
    "Tests"         "${DETECTION_RESULTS[test]:-Not detected}" \
    "Build tools"   "${DETECTION_RESULTS[build]:-Not detected}" \
    "CI/CD"         "${DETECTION_RESULTS[ci]:-Not detected}" \
    "Database"      "${DETECTION_RESULTS[database]:-Not detected}" \
    "Architecture"  "${DETECTION_RESULTS[architecture]:-Not detected}"
}

# ─── Installation plan preview ────────────────────────────────────────────────
_show_install_plan() {
  tui_section "Installation Plan"

  echo -e "  ${BOLD}What will be installed:${NC}"
  echo ""

  local vendor_desc
  vendor_desc=$(vendor_describe "${SELECTED_VENDOR}")

  echo -e "  ${DIM}Vendor:${NC}  ${BOLD}${vendor_desc}${NC}"
  echo -e "  ${DIM}Mode:${NC}    ${BOLD}${SELECTED_MODE}${NC}"
  echo ""
  echo -e "  ${DIM}Files to create:${NC}"
  echo -e "    ${GREEN}▸${NC} ${CYAN}.spectra/setup/project-profile.md${NC}"
  echo -e "    ${GREEN}▸${NC} ${CYAN}.spectra/setup/adaptation-prompt.md${NC}"
  echo -e "    ${GREEN}▸${NC} ${CYAN}.spectra/setup/spectra-conventions.md${NC}  ${DIM}(stub)${NC}"
  echo -e "    ${GREEN}▸${NC} ${CYAN}.spectra/plans/${NC}  ${DIM}(directory for planning artifacts)${NC}"

  case "${SELECTED_VENDOR}:${SELECTED_MODE}" in
    claude:agent)
      echo -e "    ${GREEN}▸${NC} ${CYAN}.claude/agents/spectra-planner.md${NC}" ;;
    claude:skill)
      echo -e "    ${GREEN}▸${NC} ${CYAN}.claude/skills/spectra-methodology/${NC}  ${DIM}(SKILL.md + resources/)${NC}" ;;
    copilot:agent)
      echo -e "    ${GREEN}▸${NC} ${CYAN}.github/agents/spectra-planner.agent.md${NC}" ;;
    copilot:skill)
      echo -e "    ${GREEN}▸${NC} ${CYAN}.github/skills/spectra-methodology/${NC}  ${DIM}(SKILL.md + resources/)${NC}" ;;
    cursor:agent)
      echo -e "    ${GREEN}▸${NC} ${CYAN}.cursor/agents/spectra-planner.mdc${NC}" ;;
    cursor:skill)
      echo -e "    ${GREEN}▸${NC} ${CYAN}.cursor/rules/spectra-methodology.mdc${NC}  ${DIM}(+ resources/)${NC}" ;;
  esac

  echo ""
  tui_confirm "Proceed with installation?" || {
    echo ""
    log_warn "Installation cancelled."
    exit 0
  }
}
