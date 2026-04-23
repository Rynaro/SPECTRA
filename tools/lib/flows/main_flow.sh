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
  local fit_only="${SPECTRA_FIT_ONLY:-false}"

  # Step 1: Welcome
  if [[ "$fit_only" == "true" ]]; then
    tui_header "Project fit — lite retrofit (no vendor install)"
    echo -e "  ${DIM}Fitting SPECTRA to: ${BOLD}${PROJECT_ROOT}${NC}"
  else
    tui_header "Intelligent Planning for AI-Assisted Development"
    echo -e "  ${DIM}Installing SPECTRA into: ${BOLD}${PROJECT_ROOT}${NC}"
  fi
  echo ""

  # Step 2: Project discovery (always)
  tui_section "Project Discovery"
  tui_spinner_start "Analyzing project structure..."
  run_all_detectors
  detect_conventions_all 2>/dev/null || true
  tui_spinner_stop
  log_ok "Project analysis complete"
  echo ""

  # Step 3: Project profile preview (always)
  _show_project_summary

  if [[ "$fit_only" == "true" ]]; then
    # Lite path: skip vendor/mode prompts and vendor install. Only
    # generate .spectra/setup/{project-profile,adaptation-prompt,
    # spectra-conventions}.md. Used by 'eidolons spectra fit' where
    # the methodology is already installed via the eidolons flow and
    # vendor dispatch is already wired — the user only needs the
    # per-project fit artefacts.
    SELECTED_VENDOR="_fit_only"
    SELECTED_MODE="_fit_only"
    _show_fit_only_plan
  else
    # Full path: pick vendor + mode, install everything.
    run_vendor_flow
    run_mode_flow
    _show_install_plan
  fi

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
    "Languages"     "${DETECTION_RESULT_LANGUAGE:-Unknown}" \
    "Frameworks"    "${DETECTION_RESULT_FRAMEWORK:-Not detected}" \
    "Tests"         "${DETECTION_RESULT_TEST:-Not detected}" \
    "Build tools"   "${DETECTION_RESULT_BUILD:-Not detected}" \
    "CI/CD"         "${DETECTION_RESULT_CI:-Not detected}" \
    "Database"      "${DETECTION_RESULT_DATABASE:-Not detected}" \
    "Architecture"  "${DETECTION_RESULT_ARCHITECTURE:-Not detected}"
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

# ─── Installation plan preview (fit-only lite path) ───────────────────────────
# Fit-only runs produce only the .spectra/setup/*.md files — no vendor
# methodology copies, no vendor dispatch files. The eidolons flow already
# handled those before invoking `eidolons spectra fit`.
_show_fit_only_plan() {
  tui_section "Fit Plan"

  echo -e "  ${BOLD}Fit-only mode:${NC} generating project-fit artefacts under .spectra/setup/"
  echo -e "  ${DIM}Vendor install skipped — the SPECTRA methodology is already wired through eidolons.${NC}"
  echo ""
  echo -e "  ${DIM}Files to create:${NC}"
  echo -e "    ${GREEN}▸${NC} ${CYAN}.spectra/setup/project-profile.md${NC}"
  echo -e "    ${GREEN}▸${NC} ${CYAN}.spectra/setup/adaptation-prompt.md${NC}"
  echo -e "    ${GREEN}▸${NC} ${CYAN}.spectra/setup/spectra-conventions.md${NC}  ${DIM}(stub)${NC}"
  echo -e "    ${GREEN}▸${NC} ${CYAN}.spectra/plans/${NC}  ${DIM}(directory for planning artifacts)${NC}"
  echo ""
  tui_confirm "Proceed with fit?" || {
    echo ""
    log_warn "Fit cancelled."
    exit 0
  }
}
