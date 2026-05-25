#!/usr/bin/env bash
# lib/vendors/copilot.sh — GitHub Copilot Vendor Adapter
# Detects and installs SPECTRA for GitHub Copilot (.github/ directory).
#
# Agent mode:   .github/agents/spectra-planner.agent.md
# Skill mode:   .github/skills/spectra-methodology/{SKILL.md,SPEC.md,resources/}
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

vendor_copilot_detect() {
  [[ -d "${PROJECT_ROOT}/.github" || \
     -f "${PROJECT_ROOT}/.github/copilot-instructions.md" || \
     -d "${PROJECT_ROOT}/.github/agents" ]]
}

vendor_copilot_describe() {
  echo "GitHub Copilot  (.github/agents/ or .github/skills/)"
}

vendor_copilot_install() {
  local mode="$1"
  case "$mode" in
    agent) _copilot_install_agent ;;
    skill) _copilot_install_skill ;;
    *)
      log_error "Unknown mode for Copilot adapter: ${mode}"
      return 1
      ;;
  esac
}

_copilot_install_agent() {
  local agents_dir="${PROJECT_ROOT}/.github/agents"
  local target="${agents_dir}/spectra-planner.agent.md"

  _copilot_ensure_dir "$agents_dir"

  if [[ -f "$target" ]]; then
    tui_confirm "spectra-planner.agent.md already exists. Overwrite?" "n" || return 0
  fi

  local spectra_content
  spectra_content=$(cat "${SPECTRA_HOME}/assets/methodology/SPEC.md")

  # Copilot agent files use a specific frontmatter format
  cat > "$target" <<AGENT_EOF
---
name: spectra-planner
description: SPECTRA planning specialist for feature design and story decomposition
---

${spectra_content}
AGENT_EOF

  track_created "$target"
  INSTALLED_FILES+=("${target}|SPECTRA planner agent (Copilot)")
  log_ok "Created: ${target}"
}

_copilot_install_skill() {
  local skill_dir="${PROJECT_ROOT}/.github/skills/spectra-methodology"
  local resources_dir="${skill_dir}/resources"

  _copilot_ensure_dir "$skill_dir"
  _copilot_ensure_dir "$resources_dir"

  _copilot_copy_asset "methodology/SKILL.md"     "${skill_dir}/SKILL.md"
  _copilot_copy_asset "methodology/SPEC.md"       "${skill_dir}/SPEC.md"
  _copilot_copy_asset "methodology/scoring.md"   "${resources_dir}/scoring.md"
  _copilot_copy_asset "methodology/templates.md" "${resources_dir}/templates.md"
}

# ─── Helpers ──────────────────────────────────────────────────────────────────

_copilot_ensure_dir() {
  if [[ ! -d "$1" ]]; then
    mkdir -p "$1"
    track_created "$1"
  fi
}

_copilot_copy_asset() {
  local src="${SPECTRA_HOME}/assets/${1}"
  local dst="$2"

  if [[ -f "$dst" ]]; then
    tui_confirm "$(basename "$dst") already exists at ${dst}. Overwrite?" "n" || return 0
  fi

  cp "$src" "$dst"
  track_created "$dst"
  INSTALLED_FILES+=("${dst}|$(basename "$src" .md) methodology file")
  log_ok "Created: ${dst}"
}

register_vendor "copilot" "vendor_copilot_detect" "vendor_copilot_install" "vendor_copilot_describe"
