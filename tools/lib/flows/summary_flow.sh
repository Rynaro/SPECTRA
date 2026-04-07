#!/usr/bin/env bash
# lib/flows/summary_flow.sh — Post-Install Summary
# Shows a branded success banner with all installed files and next steps.
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

[[ -n "${_SPECTRA_SUMMARY_FLOW_LOADED:-}" ]] && return 0
readonly _SPECTRA_SUMMARY_FLOW_LOADED=1

run_summary_flow() {
  tui_success "SPECTRA installed successfully!"

  # ── Files created ──────────────────────────────────────────────────────────
  echo -e "  ${BOLD}Files created:${NC}"
  local entry file desc
  for entry in "${INSTALLED_FILES[@]}"; do
    file="${entry%%|*}"
    desc="${entry##*|}"
    # Make path relative to project root for display
    local display_path="${file#${PROJECT_ROOT}/}"
    echo -e "    ${GREEN}▸${NC} ${CYAN}${display_path}${NC}"
    echo -e "      ${DIM}${desc}${NC}"
  done
  echo ""

  # ── Next steps ────────────────────────────────────────────────────────────
  echo -e "  ${BOLD}Next steps:${NC}"
  echo -e "    ${CYAN}1.${NC} Review ${BOLD}.spectra/setup/project-profile.md${NC} for accuracy"
  echo -e "    ${CYAN}2.${NC} Paste ${BOLD}.spectra/setup/adaptation-prompt.md${NC} into your LLM"
  echo -e "    ${CYAN}3.${NC} Save the output as ${BOLD}.spectra/setup/spectra-conventions.md${NC}"
  echo -e "    ${CYAN}4.${NC} Start planning your next feature with SPECTRA!"
  echo ""

  # ── Vendor-specific invocation hint ───────────────────────────────────────
  _show_invocation_hint

  # ── Footer ────────────────────────────────────────────────────────────────
  echo -e "  ${DIM}Learn more: ${SPECTRA_REPO}${NC}"
  echo ""
}

_show_invocation_hint() {
  case "${SELECTED_VENDOR}" in
    claude)
      if [[ "${SELECTED_MODE}" == "agent" ]]; then
        echo -e "  ${BOLD}Using SPECTRA in Claude Code:${NC}"
        echo -e "    Type ${CYAN}@spectra-planner${NC} followed by your feature description."
      else
        echo -e "  ${BOLD}Using SPECTRA in Claude Code:${NC}"
        echo -e "    Use ${CYAN}/spectra-methodology${NC} or reference it in your prompts."
      fi
      ;;
    copilot)
      if [[ "${SELECTED_MODE}" == "agent" ]]; then
        echo -e "  ${BOLD}Using SPECTRA in GitHub Copilot:${NC}"
        echo -e "    Reference ${CYAN}@spectra-planner${NC} in Copilot Chat."
      else
        echo -e "  ${BOLD}Using SPECTRA in GitHub Copilot:${NC}"
        echo -e "    Reference the skill in Copilot Chat for planning tasks."
      fi
      ;;
    cursor)
      if [[ "${SELECTED_MODE}" == "agent" ]]; then
        echo -e "  ${BOLD}Using SPECTRA in Cursor:${NC}"
        echo -e "    Open Composer and reference ${CYAN}@spectra-planner${NC}."
      else
        echo -e "  ${BOLD}Using SPECTRA in Cursor:${NC}"
        echo -e "    The rule ${CYAN}spectra-methodology${NC} is available in .cursor/rules/."
      fi
      ;;
  esac
  echo ""
}
