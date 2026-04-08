#!/usr/bin/env bash
# lib/vendors/claude.sh — Claude Code Vendor Adapter
# Detects and installs SPECTRA for Claude Code (.claude/ directory).
#
# Agent mode:   .claude/agents/spectra-planner.md
# Skill mode:   .claude/skills/spectra-methodology/{SKILL.md,SPECTRA.md,resources/}
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

vendor_claude_detect() {
  [[ -d "${PROJECT_ROOT}/.claude" || -f "${PROJECT_ROOT}/CLAUDE.md" ]]
}

vendor_claude_describe() {
  echo "Claude Code  (.claude/agents/ or .claude/skills/)"
}

vendor_claude_install() {
  local mode="$1"
  case "$mode" in
    agent) _claude_install_agent ;;
    skill) _claude_install_skill ;;
    *)
      log_error "Unknown mode for Claude adapter: ${mode}"
      return 1
      ;;
  esac
}

_claude_install_agent() {
  local agents_dir="${PROJECT_ROOT}/.claude/agents"
  local target="${agents_dir}/spectra-planner.md"

  _ensure_dir "$agents_dir"

  if [[ -f "$target" ]]; then
    tui_confirm "spectra-planner.md already exists in .claude/agents/. Overwrite?" "n" || return 0
  fi

  local spectra_content
  spectra_content=$(cat "${SPECTRA_HOME}/assets/methodology/SPECTRA.md")

  local tmpl
  tmpl=$(cat "${SPECTRA_HOME}/assets/templates/agent-planner.md.tmpl")
  tmpl="${tmpl//\{\{SPECTRA_METHODOLOGY_CONTENT\}\}/$spectra_content}"

  echo "$tmpl" > "$target"
  track_created "$target"
  INSTALLED_FILES+=("${target}|SPECTRA planner agent")
  log_ok "Created: ${target}"
}

_claude_install_skill() {
  local skill_dir="${PROJECT_ROOT}/.claude/skills/spectra-methodology"
  local resources_dir="${skill_dir}/resources"

  _ensure_dir "$skill_dir"
  _ensure_dir "$resources_dir"

  _copy_asset "methodology/SKILL.md"    "${skill_dir}/SKILL.md"
  _copy_asset "methodology/SPECTRA.md"  "${skill_dir}/SPECTRA.md"
  _copy_asset "methodology/scoring.md"  "${resources_dir}/scoring.md"
  _copy_asset "methodology/templates.md" "${resources_dir}/templates.md"
}

# ─── Helpers ──────────────────────────────────────────────────────────────────

_ensure_dir() {
  if [[ ! -d "$1" ]]; then
    mkdir -p "$1"
    track_created "$1"
  fi
}

_copy_asset() {
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

register_vendor "claude" "vendor_claude_detect" "vendor_claude_install" "vendor_claude_describe"
