#!/usr/bin/env bash
# lib/vendors/cursor.sh — Cursor Vendor Adapter
# Detects and installs SPECTRA for Cursor (.cursor/ directory or .cursorrules).
#
# Agent mode:   .cursor/agents/spectra-planner.mdc
# Skill mode:   .cursor/rules/spectra-methodology.mdc
#
# NOTE: Cursor .mdc files use YAML frontmatter + Markdown body.
# Verify current Cursor documentation if format evolves past v4.2.0.
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

vendor_cursor_detect() {
  [[ -d "${PROJECT_ROOT}/.cursor" || \
     -f "${PROJECT_ROOT}/.cursorrules" || \
     -d "${PROJECT_ROOT}/.cursor/rules" ]]
}

vendor_cursor_describe() {
  echo "Cursor  (.cursor/rules/ or .cursor/agents/)"
}

vendor_cursor_install() {
  local mode="$1"
  case "$mode" in
    agent) _cursor_install_agent ;;
    skill) _cursor_install_skill ;;
    *)
      log_error "Unknown mode for Cursor adapter: ${mode}"
      return 1
      ;;
  esac
}

_cursor_install_agent() {
  local agents_dir="${PROJECT_ROOT}/.cursor/agents"
  local target="${agents_dir}/spectra-planner.mdc"

  _cursor_ensure_dir "$agents_dir"

  if [[ -f "$target" ]]; then
    tui_confirm "spectra-planner.mdc already exists. Overwrite?" "n" || return 0
  fi

  local spectra_content
  spectra_content=$(cat "${SPECTRA_HOME}/assets/methodology/SPEC.md")

  cat > "$target" <<CURSOR_AGENT_EOF
---
description: SPECTRA planning specialist. Use for complex features where complexity >= 7/12.
alwaysApply: false
---

${spectra_content}
CURSOR_AGENT_EOF

  track_created "$target"
  INSTALLED_FILES+=("${target}|SPECTRA planner agent (Cursor)")
  log_ok "Created: ${target}"
}

_cursor_install_skill() {
  local rules_dir="${PROJECT_ROOT}/.cursor/rules"
  local target="${rules_dir}/spectra-methodology.mdc"
  local resources_dir="${rules_dir}/spectra-resources"

  _cursor_ensure_dir "$rules_dir"
  _cursor_ensure_dir "$resources_dir"

  if [[ -f "$target" ]]; then
    tui_confirm "spectra-methodology.mdc already exists. Overwrite?" "n" || return 0
  fi

  local skill_content
  skill_content=$(cat "${SPECTRA_HOME}/assets/methodology/SKILL.md")
  local spectra_content
  spectra_content=$(cat "${SPECTRA_HOME}/assets/methodology/SPEC.md")

  # Cursor skill: SKILL.md as frontmatter-driven rule, SPEC.md as reference
  cat > "$target" <<CURSOR_SKILL_EOF
---
description: SPECTRA methodology quick-reference. Use when planning features or decomposing stories.
alwaysApply: false
---

${skill_content}
CURSOR_SKILL_EOF

  track_created "$target"
  INSTALLED_FILES+=("${target}|SPECTRA methodology skill (Cursor)")
  log_ok "Created: ${target}"

  _cursor_copy_asset "methodology/SPEC.md"       "${resources_dir}/SPEC.md"
  _cursor_copy_asset "methodology/scoring.md"   "${resources_dir}/scoring.md"
  _cursor_copy_asset "methodology/templates.md" "${resources_dir}/templates.md"
}

# ─── Helpers ──────────────────────────────────────────────────────────────────

_cursor_ensure_dir() {
  if [[ ! -d "$1" ]]; then
    mkdir -p "$1"
    track_created "$1"
  fi
}

_cursor_copy_asset() {
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

register_vendor "cursor" "vendor_cursor_detect" "vendor_cursor_install" "vendor_cursor_describe"
