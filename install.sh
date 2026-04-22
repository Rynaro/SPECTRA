#!/usr/bin/env bash
# install.sh — SPECTRA EIIS-1.0 Installer
#
# Installs SPECTRA into a consumer project following the EIIS v1.0 interface
# contract. Writes methodology files to a target directory, creates per-host
# dispatch files, and emits install.manifest.json.
#
# For the full project-analysis installer (detects tech stack, generates
# adaptation prompts), see: tools/spectra-init.sh
#
# Usage: bash install.sh [OPTIONS]
#
# Options:
#   --target DIR          Target install dir (default: ./.eidolons/spectra)
#   --hosts LIST          claude-code,copilot,cursor,opencode,all (default: auto)
#   --force               Overwrite existing install
#   --dry-run             Print actions, no writes
#   --non-interactive     No prompts; fail on ambiguity (meta-installer mode)
#   --manifest-only       Only emit install.manifest.json
#   --version             Print Eidolon version
#   -h, --help            Show help
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

set -euo pipefail

readonly EIDOLON_VERSION="4.2.0"

# Handle --version and --help before the bash version check so they
# work cross-platform even on bash 3.x.
for _arg in "$@"; do
  case "$_arg" in
    --version) echo "${EIDOLON_VERSION}"; exit 0 ;;
    -h|--help)
      cat <<EOF
Usage: bash install.sh [OPTIONS]

Installs SPECTRA v${EIDOLON_VERSION} into a consumer project (EIIS v1.0).

Options:
  --target DIR          Target install dir (default: ./.eidolons/spectra)
  --hosts LIST          claude-code,copilot,cursor,opencode,all (default: auto)
  --force               Overwrite existing install
  --dry-run             Print actions, no writes
  --non-interactive     No prompts; fail on ambiguity (meta-installer mode)
  --manifest-only       Only emit install.manifest.json
  --version             Print Eidolon version
  -h, --help            Show help

Examples:
  bash install.sh
  bash install.sh --target ./.eidolons/spectra --hosts claude-code,copilot
  bash install.sh --dry-run
  bash install.sh --non-interactive --hosts all

For project analysis + adaptation prompts (direct SPECTRA adoption):
  bash tools/spectra-init.sh [/path/to/project]
EOF
      exit 0 ;;
  esac
done

# (Runs under bash 3.2+ — macOS default. `mapfile` below replaced with a
# while-read loop so Homebrew bash is not a prerequisite.)

readonly EIDOLON_NAME="spectra"
readonly METHODOLOGY="SPECTRA"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source files (relative to SCRIPT_DIR)
readonly SRC_AGENT="${SCRIPT_DIR}/agent.md"
readonly SRC_SPECTRA="${SCRIPT_DIR}/docs/spectra-methodology/SPECTRA.md"
readonly SRC_SKILL="${SCRIPT_DIR}/docs/spectra-methodology/SKILL.md"
readonly SRC_SCORING="${SCRIPT_DIR}/docs/spectra-methodology/scoring.md"
readonly SRC_TEMPLATES="${SCRIPT_DIR}/docs/spectra-methodology/templates.md"
readonly SRC_PLANNING_ARTIFACT="${SCRIPT_DIR}/templates/planning-artifact.md"

# Defaults
TARGET="./.eidolons/${EIDOLON_NAME}"
HOSTS="auto"
FORCE=false
DRY_RUN=false
NON_INTERACTIVE=false
MANIFEST_ONLY=false

# --- Argument parsing ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)           TARGET="$2"; shift 2 ;;
    --hosts)            HOSTS="$2";  shift 2 ;;
    --force)            FORCE=true;  shift ;;
    --dry-run)          DRY_RUN=true; shift ;;
    --non-interactive)  NON_INTERACTIVE=true; shift ;;
    --manifest-only)    MANIFEST_ONLY=true; shift ;;
    --version)          echo "${EIDOLON_VERSION}"; exit 0 ;;
    -h|--help)          exit 0 ;;
    *)                  echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

# --- Logging helpers ---
log_ok()   { echo "✓ $*"; }
log_info() { echo "  $*"; }
log_warn() { echo "⚠ $*" >&2; }
log_dry()  { echo "[dry-run] $*"; }

# --- Host detection ---
detect_hosts() {
  local detected=()
  [[ -f "CLAUDE.md" || -d ".claude" ]]           && detected+=("claude-code")
  [[ -d ".github" ]]                              && detected+=("copilot")
  [[ -d ".cursor" || -f ".cursorrules" ]]         && detected+=("cursor")
  [[ -d ".opencode" ]]                            && detected+=("opencode")
  printf '%s\n' "${detected[@]+"${detected[@]}"}"
}

if [[ "$HOSTS" == "auto" ]]; then
  _detected=()
  while IFS= read -r _line; do
    [[ -n "$_line" ]] && _detected+=("$_line")
  done < <(detect_hosts)
  if [[ ${#_detected[@]} -eq 0 ]]; then
    HOSTS="none"
    log_warn "No host environments detected. Methodology files will be installed to ${TARGET}/ only."
    log_warn "Use --hosts to specify: claude-code,copilot,cursor,opencode,all"
  else
    HOSTS="$(printf '%s\n' "${_detected[@]}" | paste -sd,)"
  fi
fi
[[ "$HOSTS" == "all" ]] && HOSTS="claude-code,copilot,cursor,opencode"

# --- Idempotency check ---
MANIFEST_PATH="${TARGET}/install.manifest.json"
if [[ -f "$MANIFEST_PATH" && "$FORCE" != "true" && "$DRY_RUN" != "true" ]]; then
  EXISTING_VER=$(grep -o '"version":"[^"]*"' "$MANIFEST_PATH" 2>/dev/null | head -1 | cut -d'"' -f4 || echo "unknown")
  if [[ "$NON_INTERACTIVE" == "true" ]]; then
    echo "Existing install v${EXISTING_VER} at ${TARGET}. Pass --force to overwrite." >&2
    exit 3
  fi
  read -rp "Existing install v${EXISTING_VER} at ${TARGET}. Overwrite? [y/N] " _confirm
  [[ "$_confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

# --- Validate source files ---
if [[ "$MANIFEST_ONLY" != "true" ]]; then
  for _f in "$SRC_AGENT" "$SRC_SPECTRA" "$SRC_SKILL" "$SRC_SCORING" "$SRC_TEMPLATES" "$SRC_PLANNING_ARTIFACT"; do
    if [[ ! -f "$_f" ]]; then
      echo "Error: source file not found: ${_f}" >&2
      echo "Run this script from the SPECTRA repo root or a full clone." >&2
      exit 1
    fi
  done
fi

# Relative form of TARGET for @-pointers (strips leading ./)
TARGET_REL="${TARGET#./}"

# --- SHA-256 helper ---
sha256_of() {
  if command -v sha256sum &>/dev/null; then
    sha256sum "$1" | cut -d' ' -f1
  elif command -v shasum &>/dev/null; then
    shasum -a 256 "$1" | cut -d' ' -f1
  else
    echo "unavailable"
  fi
}

# Accumulate written files for manifest: "path|role|mode"
FILES_WRITTEN=()
HOSTS_WIRED=()

# --- Copy a source file to the target directory ---
copy_file() {
  local src="$1" dst="$2" role="$3"
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry "cp $(basename "$src") → ${dst}"
    return
  fi
  cp "$src" "$dst"
  FILES_WRITTEN+=("${dst}|${role}|created")
  log_ok "Wrote: ${dst}"
}

# --- Write inline content to a file ---
write_file() {
  local dst="$1" role="$2" mode="$3" content="$4"
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry "${mode}: ${dst}"
    return
  fi
  if [[ "$mode" == "appended" ]]; then
    printf '%s\n' "$content" >> "$dst"
  else
    printf '%s\n' "$content" > "$dst"
  fi
  FILES_WRITTEN+=("${dst}|${role}|${mode}")
  log_ok "${mode}: ${dst}"
}

echo ""
echo "Installing SPECTRA v${EIDOLON_VERSION} → ${TARGET}"
echo "Hosts:  ${HOSTS}"
echo ""

# --- Install methodology files ---
if [[ "$MANIFEST_ONLY" != "true" ]]; then
  if [[ "$DRY_RUN" != "true" ]]; then
    mkdir -p "$TARGET" "${TARGET}/templates"
  else
    log_dry "mkdir -p ${TARGET} ${TARGET}/templates"
  fi

  copy_file "$SRC_AGENT"             "${TARGET}/agent.md"                       "entry-point"
  copy_file "$SRC_SPECTRA"           "${TARGET}/SPECTRA.md"                     "spec"
  copy_file "$SRC_SKILL"             "${TARGET}/SKILL.md"                       "skill"
  copy_file "$SRC_SCORING"           "${TARGET}/scoring.md"                     "spec"
  copy_file "$SRC_TEMPLATES"         "${TARGET}/templates.md"                   "template"
  copy_file "$SRC_PLANNING_ARTIFACT" "${TARGET}/templates/planning-artifact.md" "template"

  # --- Per-host dispatch files ---
  IFS=',' read -ra _host_list <<< "$HOSTS"

  for _host in "${_host_list[@]}"; do
    _host="${_host// /}"  # trim whitespace
    case "$_host" in

      claude-code)
        HOSTS_WIRED+=("claude-code")
        if [[ -f "CLAUDE.md" ]]; then
          if ! grep -qE "(\.eidolons|agents)/${EIDOLON_NAME}/agent\.md" "CLAUDE.md" 2>/dev/null; then
            write_file "CLAUDE.md" "dispatch" "appended" \
"
## SPECTRA Planning Agent

\`@${TARGET_REL}/agent.md\`"
          else
            log_info "CLAUDE.md already references SPECTRA — skipping"
          fi
        fi

        # Subagent dispatch — authoritative when claude-code is wired
        if [[ "$DRY_RUN" != "true" ]]; then
          mkdir -p ".claude/agents"
          if [[ ! -f ".claude/agents/${EIDOLON_NAME}.md" || "$FORCE" == "true" ]]; then
            cat > ".claude/agents/${EIDOLON_NAME}.md" <<AGENT
---
name: ${EIDOLON_NAME}
description: "Decision-ready specifications — scoring rubrics, validation gates, GIVEN/WHEN/THEN stories."
when_to_use: "After ATLAS has mapped the surface (or you have an equivalent brief) and you need a bounded, testable spec before implementation begins."
tools: Read, Grep, Glob, Write
methodology: ${METHODOLOGY}
methodology_version: "${EIDOLON_VERSION%.*}"
role: Planner — decision-ready specifications
handoffs: [apivr]
---

SPECTRA runs the S→P→E→C→T→R→A cycle. Given an exploration or scout
report, it produces a spec with scoring rubrics, validation gates, and
structured stories that downstream implementers can act on without
ambiguity.

See \`${TARGET}/agent.md\` for P0 rules and
\`${TARGET}/SPECTRA.md\` for the full specification. Skills load on
demand — see \`${TARGET}/SKILL.md\`.
AGENT
            FILES_WRITTEN+=(".claude/agents/${EIDOLON_NAME}.md|dispatch|created")
            log_ok "Wrote: .claude/agents/${EIDOLON_NAME}.md"
          else
            log_info ".claude/agents/${EIDOLON_NAME}.md already exists — use --force to overwrite"
          fi
        else
          log_dry "write: .claude/agents/${EIDOLON_NAME}.md"
        fi
        ;;

      copilot)
        HOSTS_WIRED+=("copilot")
        [[ "$DRY_RUN" != "true" ]] && mkdir -p ".github"
        if [[ ! -f ".github/copilot-instructions.md" ]]; then
          write_file ".github/copilot-instructions.md" "dispatch" "created" \
"# GitHub Copilot — SPECTRA methodology

The SPECTRA planning agent is installed at \`${TARGET}/\`.

- Entry point: \`${TARGET}/agent.md\`
- Full spec:   \`${TARGET}/SPECTRA.md\`
- Quick ref:   \`${TARGET}/SKILL.md\`

SPECTRA produces specifications, never code. READ-ONLY during all planning phases."
        elif ! grep -qE "(\.eidolons|agents)/${EIDOLON_NAME}" ".github/copilot-instructions.md" 2>/dev/null; then
          write_file ".github/copilot-instructions.md" "dispatch" "appended" \
"
## SPECTRA Planning Agent

The SPECTRA planning agent is installed at \`${TARGET}/\`.
Entry point: \`${TARGET}/agent.md\`"
        else
          log_info ".github/copilot-instructions.md already references SPECTRA — skipping"
        fi
        ;;

      cursor)
        HOSTS_WIRED+=("cursor")
        if [[ -d ".cursor" || -f ".cursorrules" ]]; then
          [[ "$DRY_RUN" != "true" ]] && mkdir -p ".cursor/rules"
          _mdc=".cursor/rules/${EIDOLON_NAME}.mdc"
          if [[ ! -f "$_mdc" || "$FORCE" == "true" ]]; then
            write_file "$_mdc" "dispatch" "created" \
"---
description: SPECTRA planning methodology
alwaysApply: false
---

# SPECTRA — Planning Specialist

Entry point: \`${TARGET}/agent.md\`
Full spec:   \`${TARGET}/SPECTRA.md\`

SPECTRA produces specifications, never code. Activate for tasks with complexity ≥7/12."
          else
            log_info ".cursor/rules/${EIDOLON_NAME}.mdc already exists — use --force to overwrite"
          fi
        else
          log_warn "cursor host requested but no .cursor/ dir found — skipping dispatch file"
        fi
        ;;

      opencode)
        HOSTS_WIRED+=("opencode")
        if [[ -d ".opencode" ]]; then
          [[ "$DRY_RUN" != "true" ]] && mkdir -p ".opencode/agents"
          _oc=".opencode/agents/${EIDOLON_NAME}.md"
          if [[ ! -f "$_oc" || "$FORCE" == "true" ]]; then
            write_file "$_oc" "dispatch" "created" \
"# SPECTRA — Planning Specialist

Entry point: \`${TARGET}/agent.md\`
Full spec:   \`${TARGET}/SPECTRA.md\`

SPECTRA produces specifications, never code. Activate for tasks with complexity ≥7/12."
          else
            log_info ".opencode/agents/${EIDOLON_NAME}.md already exists — use --force to overwrite"
          fi
        else
          log_warn "opencode host requested but no .opencode/ dir found — skipping dispatch file"
        fi
        ;;

      none|"")
        ;;
      *)
        log_warn "Unknown host '${_host}' — skipping"
        ;;
    esac
  done
fi

# --- Measure agent.md tokens ---
AGENT_TOKENS=0
_agent_target="${TARGET}/agent.md"
if [[ -f "$_agent_target" ]]; then
  _wc=$(wc -w < "$_agent_target")
  AGENT_TOKENS=$(awk "BEGIN {printf \"%d\", ${_wc}/0.75}")
elif [[ -f "$SRC_AGENT" ]]; then
  _wc=$(wc -w < "$SRC_AGENT")
  AGENT_TOKENS=$(awk "BEGIN {printf \"%d\", ${_wc}/0.75}")
fi

# --- Emit install.manifest.json ---
if [[ "$DRY_RUN" != "true" ]]; then
  mkdir -p "$TARGET"

  # Build files_written JSON array
  _files_json="["
  _first=true
  for _entry in "${FILES_WRITTEN[@]+"${FILES_WRITTEN[@]}"}"; do
    IFS='|' read -r _fpath _frole _fmode <<< "$_entry"
    _fsha=$(sha256_of "$_fpath" 2>/dev/null || echo "")
    [[ "$_first" == "true" ]] && _first=false || _files_json+=","
    _files_json+="{\"path\":\"${_fpath}\",\"sha256\":\"${_fsha}\",\"role\":\"${_frole}\",\"mode\":\"${_fmode}\"}"
  done
  _files_json+="]"

  # Build hosts_wired JSON array
  _hosts_json="["
  _first=true
  for _h in "${HOSTS_WIRED[@]+"${HOSTS_WIRED[@]}"}"; do
    [[ "$_first" == "true" ]] && _first=false || _hosts_json+=","
    _hosts_json+="\"${_h}\""
  done
  _hosts_json+="]"

  _installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "1970-01-01T00:00:00Z")

  cat > "$MANIFEST_PATH" <<MANIFEST_EOF
{
  "eidolon": "${EIDOLON_NAME}",
  "version": "${EIDOLON_VERSION}",
  "methodology": "${METHODOLOGY}",
  "installed_at": "${_installed_at}",
  "target": "${TARGET}",
  "hosts_wired": ${_hosts_json},
  "files_written": ${_files_json},
  "handoffs_declared": {
    "upstream": [],
    "downstream": []
  },
  "token_budget": {
    "entry": ${AGENT_TOKENS},
    "working_set_target": 1000
  },
  "security": {
    "reads_repo": true,
    "reads_network": false,
    "writes_repo": true,
    "persists": ["${TARGET}/"]
  }
}
MANIFEST_EOF
  log_ok "Manifest: ${MANIFEST_PATH}"
else
  log_dry "write: ${MANIFEST_PATH}"
fi

# --- Token report ---
echo ""
echo "✓ agent.md: ${AGENT_TOKENS} tokens (budget: ≤1000)"
if [[ "$AGENT_TOKENS" -gt 1000 ]]; then
  log_warn "agent.md exceeds 1000-token budget (${AGENT_TOKENS} tokens)"
  if [[ "$NON_INTERACTIVE" == "true" ]]; then
    exit 4
  fi
fi

# --- Smoke-test banner ---
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " SPECTRA v${EIDOLON_VERSION} installed → ${TARGET}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo " Smoke test — paste into your AI host:"
echo ""
echo '   "Using SPECTRA, plan: add a health check endpoint to a'
echo '    REST API returning service status and version."'
echo ""
echo " Expected: CLARIFY → Scope → Pattern → Explore → Construct"
echo "           → Test → Assemble. No code. Dual-format artifact."
echo ""
echo " Full smoke missions: evals/canary-missions.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
