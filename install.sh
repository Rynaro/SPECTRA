#!/usr/bin/env bash
# install.sh — SPECTRA EIIS v1.4 Installer
#
# Installs SPECTRA into a consumer project following the EIIS v1.4 interface
# contract. Writes methodology files to a target directory, creates per-host
# dispatch files (claude-code, copilot, cursor, opencode, codex), and emits
# install.manifest.json.
#
# For the full project-analysis installer (detects tech stack, generates
# adaptation prompts), see: tools/spectra-init.sh
#
# Usage: bash install.sh [OPTIONS]
#
# Options:
#   --target DIR          Target install dir (default: ./.eidolons/spectra)
#   --hosts LIST          claude-code,copilot,cursor,opencode,codex,all
#                         (default: auto)
#   --force               Overwrite existing install
#   --dry-run             Print actions, no writes
#   --non-interactive     No prompts; fail on ambiguity (meta-installer mode)
#   --manifest-only       Only emit install.manifest.json
#   --version             Print Eidolon version
#   -h, --help            Show help
#
# SPECTRA v4.5.1+ — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

set -euo pipefail

readonly EIDOLON_VERSION="4.6.0"

# Handle --version and --help before the bash version check so they
# work cross-platform even on bash 3.x.
for _arg in "$@"; do
  case "$_arg" in
    --version) echo "${EIDOLON_VERSION}"; exit 0 ;;
    -h|--help)
      cat <<EOF
Usage: bash install.sh [OPTIONS]

Installs SPECTRA v${EIDOLON_VERSION} into a consumer project (EIIS v1.4).

Options:
  --target DIR          Target install dir (default: ./.eidolons/spectra)
  --hosts LIST          claude-code,copilot,cursor,opencode,codex,all
                        (default: auto)
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
  bash install.sh --hosts codex

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

# Legacy artefacts swept by cleanup_legacy_v1_2 on upgrade.
# v1.4: adds scoring.md and templates.md (moved under templates/ in v4.5.0).
# Bash 3.2 compatible: indexed arrays only.
LEGACY_SPEC_FILES=( "SPECTRA.md" "scoring.md" "templates.md" )
LEGACY_SKILL_DIRS=( \
  "planning" \
)
# v1.4: non-whitelisted directories previously installed (research, tools, commands).
# cleanup_legacy_v1_2 handles skill dirs but not arbitrary top-level dirs;
# canonical_inventory_sweep (invoked at install-end) is the normative gate.
# We declare them here for reference; the belt-and-braces rm -rf below handles early sweep.
LEGACY_EXTRA_DIRS=( "research" "tools" "commands" )

# ECL version emitted by this Eidolon — tolerate absence for older tarballs.
ECL_VERSION_EMITTED=""
if [[ -f "${SCRIPT_DIR}/ECL_VERSION" ]]; then
  ECL_VERSION_EMITTED="$(head -1 "${SCRIPT_DIR}/ECL_VERSION" | tr -d '[:space:]')"
fi

# Source files (relative to SCRIPT_DIR)
readonly SRC_AGENT="${SCRIPT_DIR}/agent.md"
readonly SRC_SPEC="${SCRIPT_DIR}/docs/spectra-methodology/SPEC.md"
readonly SRC_SCORING="${SCRIPT_DIR}/docs/spectra-methodology/scoring.md"
readonly SRC_TEMPLATES="${SCRIPT_DIR}/docs/spectra-methodology/catalog.md"
readonly SRC_PLANNING_ARTIFACT="${SCRIPT_DIR}/templates/planning-artifact.md"
readonly SRC_SKILLS_DIR="${SCRIPT_DIR}/skills"
readonly SRC_ECL_VERSION="${SCRIPT_DIR}/ECL_VERSION"
readonly SRC_SPEC_PROFILE="${SCRIPT_DIR}/schemas/spec-profile.v1.json"
readonly SRC_ECL_ENVELOPE="${SCRIPT_DIR}/schemas/ecl-envelope.v1.json"
readonly SRC_SPEC_ENVELOPE_TMPL="${SCRIPT_DIR}/templates/spec.envelope.json"

# Defaults
TARGET="./.eidolons/${EIDOLON_NAME}"
HOSTS="auto"
FORCE=false
DRY_RUN=false
NON_INTERACTIVE=false
MANIFEST_ONLY=false
SHARED_DISPATCH=false

# --- Argument parsing ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)               TARGET="$2"; shift 2 ;;
    --hosts)                HOSTS="$2";  shift 2 ;;
    --shared-dispatch)      SHARED_DISPATCH=true; shift ;;
    --no-shared-dispatch)   SHARED_DISPATCH=false; shift ;;
    --force)                FORCE=true;  shift ;;
    --dry-run)              DRY_RUN=true; shift ;;
    --non-interactive)      NON_INTERACTIVE=true; shift ;;
    --manifest-only)        MANIFEST_ONLY=true; shift ;;
    --version)              echo "${EIDOLON_VERSION}"; exit 0 ;;
    -h|--help)              exit 0 ;;
    *)                      echo "Unknown option: $1" >&2; exit 2 ;;
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
  # Codex (EIIS v1.1 §4.5): `.codex/` is the definitive Codex-only signal.
  # Root `AGENTS.md` without `.github/` and without `.codex/` is treated as
  # a Codex-only project per the cross-vendor agents.md convention
  # (https://developers.openai.com/codex/guides/agents-md).
  if [[ -d ".codex" ]]; then
    detected+=("codex")
  elif [[ -f "AGENTS.md" && ! -d ".github" ]]; then
    detected+=("codex")
  fi
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
    log_warn "Use --hosts to specify: claude-code,copilot,cursor,opencode,codex,all"
  else
    HOSTS="$(printf '%s\n' "${_detected[@]}" | paste -sd,)"
  fi
fi
[[ "$HOSTS" == "all" ]] && HOSTS="claude-code,copilot,cursor,opencode,codex"

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
  for _f in "$SRC_AGENT" "$SRC_SPEC" "$SRC_SCORING" "$SRC_TEMPLATES" "$SRC_PLANNING_ARTIFACT"; do
    if [[ ! -f "$_f" ]]; then
      echo "Error: source file not found: ${_f}" >&2
      echo "Run this script from the SPECTRA repo root or a full clone." >&2
      exit 1
    fi
  done
  if [[ ! -d "$SRC_SKILLS_DIR" ]]; then
    echo "Error: skills source directory not found: ${SRC_SKILLS_DIR}" >&2
    exit 1
  fi
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

# cleanup_legacy_v1_2 <target>
#
# Sweep legacy artefacts left behind by prior installs.
# Called exactly once, early in the install sequence, BEFORE any new content
# is written under <target>. Idempotent: no-op when no legacy file exists.
#
# Reads top-of-file arrays:
#   LEGACY_SPEC_FILES  — basenames to rm -f at "<target>/<basename>"
#   LEGACY_SKILL_DIRS  — skill names to rm -rf at "<target>/skills/<name>"
#   LEGACY_EXTRA_DIRS  — top-level dirs to rm -rf at "<target>/<dir>"
#
# All arrays are declared per-Eidolon and MAY be empty (in which case
# the corresponding loop is a no-op). Never reads/writes outside <target>.
cleanup_legacy_v1_2() {
  local target="$1"
  local legacy
  local legacy_skill_dir
  local legacy_dir

  if [ -z "${target}" ] || [ ! -d "${target}" ]; then
    return 0
  fi

  # Sweep legacy spec filenames (e.g. SPECTRA.md from pre-v1.3 installs;
  # scoring.md and templates.md at root from pre-v4.5.0 installs).
  for legacy in "${LEGACY_SPEC_FILES[@]}"; do
    if [ -n "${legacy}" ] && [ -f "${target}/${legacy}" ]; then
      rm -f "${target}/${legacy}"
      log_info "swept legacy spec file: ${target}/${legacy}"
    fi
  done

  # Sweep legacy subdir-style skills (e.g. skills/planning/SKILL.md)
  for legacy_skill_dir in "${LEGACY_SKILL_DIRS[@]}"; do
    if [ -n "${legacy_skill_dir}" ] && [ -d "${target}/skills/${legacy_skill_dir}" ]; then
      rm -rf "${target}/skills/${legacy_skill_dir}"
      log_info "swept legacy skill subdir: ${target}/skills/${legacy_skill_dir}"
    fi
  done

  # Sweep non-whitelisted top-level dirs installed by pre-v4.5.0 releases
  # (research/, tools/, commands/ — no longer in the §1.9.1 canonical whitelist).
  for legacy_dir in "${LEGACY_EXTRA_DIRS[@]+"${LEGACY_EXTRA_DIRS[@]}"}"; do
    if [ -n "${legacy_dir}" ] && [ -d "${target}/${legacy_dir}" ]; then
      rm -rf "${target}/${legacy_dir}"
      log_info "swept non-whitelisted dir: ${target}/${legacy_dir}"
    fi
  done

  return 0
}

# canonical_inventory_sweep <target>
#
# Remove every file under <target>/ that is not present in the in-memory
# allow-set FILES_WRITTEN_PATHS. Manifest-driven: runs AFTER all writes,
# BEFORE install.manifest.json is finalized. Replaces per-Eidolon ad-hoc
# cleanup with a contract-based sweep (EIIS v1.4 §6.X).
#
# Bash 3.2 compatible: indexed array, no associative arrays, no readarray.
# Idempotent: re-running on a clean target is a no-op.
canonical_inventory_sweep() {
  local target="$1"
  local file_rel
  local found
  local known

  if [ -z "${target}" ] || [ ! -d "${target}" ]; then
    return 0
  fi

  # Walk every file under <target>/; for each, test membership in the allow-set.
  find "${target}" -type f -print0 | while IFS= read -r -d '' file; do
    # Compute the target-relative path (strip "${target}/" prefix).
    file_rel="${file#${target}/}"

    found=0
    for known in "${FILES_WRITTEN_PATHS[@]+"${FILES_WRITTEN_PATHS[@]}"}"; do
      # FILES_WRITTEN_PATHS entries are consumer-relative
      # (e.g. ".eidolons/spectra/SPEC.md"). Compare by suffix.
      case "${known}" in
        *"/${file_rel}"|"${file_rel}")
          found=1
          break
          ;;
      esac
    done

    if [ "${found}" -eq 0 ]; then
      rm -f "${file}"
      log_info "swept non-whitelisted file: ${file}"
    fi
  done

  # Remove any empty directories left after the sweep.
  find "${target}" -mindepth 1 -type d -empty -delete 2>/dev/null || true

  return 0
}

# Accumulate written files for manifest: "path|role|mode"
FILES_WRITTEN=()
# Parallel allow-set for canonical_inventory_sweep: consumer-relative paths.
FILES_WRITTEN_PATHS=()
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
  FILES_WRITTEN_PATHS+=("${dst}")
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
  FILES_WRITTEN_PATHS+=("${dst}")
  log_ok "${mode}: ${dst}"
}

# upsert_eidolon_block <file> <content>
#
# Owns a marker-bounded region in a composable dispatch file (CLAUDE.md,
# AGENTS.md, .github/copilot-instructions.md). Rewrites the body in place
# when markers already exist; appends a new block otherwise. Cleans up
# any pre-existing symlink at the target.
upsert_eidolon_block() {
  local dst="$1" content="$2"
  local start="<!-- eidolon:${EIDOLON_NAME} start -->"
  local end="<!-- eidolon:${EIDOLON_NAME} end -->"

  if [[ "$DRY_RUN" == "true" ]]; then
    local action="append"
    [[ -f "$dst" ]] && grep -qF "$start" "$dst" 2>/dev/null && action="rewrite"
    log_dry "${action} eidolon:${EIDOLON_NAME} block in ${dst}"
    return
  fi

  mkdir -p "$(dirname "$dst")" 2>/dev/null || true
  [[ -L "$dst" ]] && rm -f "$dst"

  local content_file tmp mode
  content_file="$(mktemp)"
  printf '%s\n' "$content" > "$content_file"

  if [[ -f "$dst" ]] && grep -qF "$start" "$dst" 2>/dev/null; then
    mode="rewritten"
    tmp="$(mktemp)"
    awk -v start="$start" -v end="$end" -v cf="$content_file" '
      BEGIN { in_block = 0 }
      $0 == start {
        print start
        while ((getline line < cf) > 0) print line
        close(cf)
        in_block = 1
        next
      }
      $0 == end {
        print end
        in_block = 0
        next
      }
      !in_block { print }
    ' "$dst" > "$tmp"
    mv "$tmp" "$dst"
  elif [[ -f "$dst" ]]; then
    mode="appended"
    { printf '\n%s\n' "$start"; cat "$content_file"; printf '%s\n' "$end"; } >> "$dst"
  else
    mode="created"
    { printf '%s\n' "$start"; cat "$content_file"; printf '%s\n' "$end"; } > "$dst"
  fi

  rm -f "$content_file"
  FILES_WRITTEN+=("${dst}|dispatch|${mode}")
  log_ok "${mode}: ${dst} (eidolon:${EIDOLON_NAME} block)"
}

echo ""
echo "Installing SPECTRA v${EIDOLON_VERSION} → ${TARGET}"
echo "Hosts:  ${HOSTS}"
echo ""

# --- Install methodology files ---
if [[ "$MANIFEST_ONLY" != "true" ]]; then
  if [[ "$DRY_RUN" != "true" ]]; then
    mkdir -p "$TARGET" "${TARGET}/templates" "${TARGET}/schemas"
  else
    log_dry "mkdir -p ${TARGET} ${TARGET}/templates ${TARGET}/schemas"
  fi

  # Sweep legacy v1.2-era artefacts before writing any new content.
  cleanup_legacy_v1_2 "${TARGET}"

  copy_file "$SRC_AGENT"             "${TARGET}/agent.md"                       "agent-profile"
  copy_file "$SRC_SPEC"              "${TARGET}/SPEC.md"                        "spec"
  copy_file "$SRC_SCORING"           "${TARGET}/templates/scoring.md"           "template"
  copy_file "$SRC_TEMPLATES"         "${TARGET}/templates/catalog.md"           "template"
  copy_file "$SRC_PLANNING_ARTIFACT" "${TARGET}/templates/planning-artifact.md" "template"

  # ECL v1.0 emission files (opt-in — only present when ECL_VERSION exists)
  if [[ -f "$SRC_ECL_VERSION" ]]; then
    copy_file "$SRC_ECL_VERSION"          "${TARGET}/ECL_VERSION"                          "ecl-version"
    copy_file "$SRC_SPEC_PROFILE"         "${TARGET}/schemas/spec-profile.v1.json"         "other"
    copy_file "$SRC_ECL_ENVELOPE"         "${TARGET}/schemas/ecl-envelope.v1.json"         "other"
    # spec.envelope.json is a JSON template — moved to schemas/ (EIIS v1.4 §1.9.1:
    # templates/ allows only .md; schemas/ allows .json).
    copy_file "$SRC_SPEC_ENVELOPE_TMPL"   "${TARGET}/schemas/spec.envelope.json"           "other"
  fi

  # NOTE (v4.5.0 / EIIS v1.4): research/, tools/, and commands/ are no longer
  # copied to the install target — those paths fall outside the §1.9.1 canonical
  # inventory whitelist. Consumers that need the research citations or retrofit
  # tooling should reference the SPECTRA source repo directly, or clone it locally.
  # The LEGACY_SPEC_FILES array extended in cleanup_legacy_v1_2 will sweep any
  # stale copies left by prior installs; the manifest-driven canonical_inventory_sweep
  # at install-end is the normative gate (EIIS v1.4 §6.X).

  # --- Per-host dispatch files ---
  IFS=',' read -ra _host_list <<< "$HOSTS"

  # Shared composable block — emitted identically to AGENTS.md, CLAUDE.md,
  # .github/copilot-instructions.md. Each Eidolon owns its marker-bounded
  # section within these files. Gated behind --shared-dispatch (opt-in).
  SHARED_BLOCK="## SPECTRA — Decision-ready specifications (v${EIDOLON_VERSION})

Entry:     \`${TARGET_REL}/agent.md\`
Full spec: \`${TARGET_REL}/SPEC.md\`
Cycle:     CLARIFY → Scope → Pattern → Explore → Construct → Test → Refine → Assemble

**P0 (non-negotiable):** READ-ONLY during all planning phases (no code edits); dual-format output (Markdown + YAML/JSON); CLARIFY first (parse WHO/WHAT/WHY/CONSTRAINTS); confidence ≥85% at Assemble (else Refine, max 3 cycles); output is a specification, never an implementation."

  # --- Per-skill vendor wiring (EIIS v1.3 §4.2.4 dual-write) ---
  #
  # wire_skill <skill_name>
  #
  # Dual-writes a skill file per EIIS v1.3 §4.2.4:
  #   - source-of-truth (flat): ${TARGET}/skills/<skill_name>.md
  #   - vendor copy:            .claude/skills/spectra-<skill_name>/SKILL.md
  #
  # Source file resolved as: ${SRC_SKILLS_DIR}/<skill_name>.md
  # Bash 3.2 compatible (no declare -A, no ${var,,}, no readarray).
  strip_frontmatter() {
    local f="$1"
    if [[ "$(head -1 "$f")" == "---" ]]; then
      awk 'NR==1 && /^---$/ {in_fm=1; next}
           in_fm && /^---$/ {in_fm=0; next}
           !in_fm {print}' "$f"
    else
      cat "$f"
    fi
  }
  extract_fm_field() {
    awk -v field="$2" '
      NR==1 && /^---$/ { in_fm=1; next }
      in_fm && /^---$/ { exit }
      in_fm { p=index($0, field ":"); if (p==1) { sub("^" field ":[[:space:]]*", ""); print; exit } }
    ' "$1"
  }
  wire_skill() {
    local skill="$1"
    local src="${SRC_SKILLS_DIR}/${skill}.md"
    local dst_src="${TARGET}/skills/${skill}.md"
    local dst_vendor=".claude/skills/${EIDOLON_NAME}-${skill}/SKILL.md"

    if [[ ! -f "${src}" ]]; then
      log_warn "skill source not found: ${src}"
      return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
      log_dry "skill source-of-truth: ${dst_src}"
      log_dry "skill vendor copy:     ${dst_vendor}"
      return
    fi

    # Source-of-truth flat write (always, host-independent)
    mkdir -p "$(dirname "${dst_src}")"
    cp "${src}" "${dst_src}"
    FILES_WRITTEN+=("${dst_src}|skill|created")
    FILES_WRITTEN_PATHS+=("${dst_src}")
    log_ok "Wrote: ${dst_src}"

    # Vendor copy for claude-code host
    if printf '%s\n' "${HOSTS}" | grep -q 'claude-code'; then
      mkdir -p "$(dirname "${dst_vendor}")"
      cp "${src}" "${dst_vendor}"
      FILES_WRITTEN+=("${dst_vendor}|skill|created")
      log_ok "Wrote: ${dst_vendor}"
    fi

    # Copilot vendor copy
    local description
    description="$(extract_fm_field "${src}" "description")"
    [[ -z "$description" ]] && description="${skill}"
    if printf '%s\n' "${HOSTS}" | grep -q 'copilot'; then
      local dst_copilot=".github/instructions/${EIDOLON_NAME}-${skill}.instructions.md"
      mkdir -p ".github/instructions"
      { echo "---"; echo "applyTo: \"**\""; echo "description: \"${description}\""; echo "---"; strip_frontmatter "${src}"; } > "${dst_copilot}"
      FILES_WRITTEN+=("${dst_copilot}|skill|created")
      log_ok "Wrote: ${dst_copilot}"
    fi

    # Cursor vendor copy
    if printf '%s\n' "${HOSTS}" | grep -q 'cursor'; then
      local dst_cursor=".cursor/rules/${EIDOLON_NAME}-${skill}.mdc"
      mkdir -p ".cursor/rules"
      { echo "---"; echo "description: \"${description}\""; echo "alwaysApply: false"; echo "---"; strip_frontmatter "${src}"; } > "${dst_cursor}"
      FILES_WRITTEN+=("${dst_cursor}|skill|created")
      log_ok "Wrote: ${dst_cursor}"
    fi
  }

  # Emit per-skill files for every flat skill source.
  mkdir -p "${TARGET}/skills"
  for _skill_src in "${SRC_SKILLS_DIR}"/*.md; do
    [[ -f "$_skill_src" ]] || continue
    _skill_slug="$(basename "${_skill_src}" .md)"
    wire_skill "${_skill_slug}"
  done

  # AGENTS.md (shared dispatch) — opt-in only.
  [[ "$SHARED_DISPATCH" == "true" ]] && upsert_eidolon_block "AGENTS.md" "$SHARED_BLOCK"

  for _host in "${_host_list[@]}"; do
    _host="${_host// /}"  # trim whitespace
    case "$_host" in

      claude-code)
        HOSTS_WIRED+=("claude-code")
        [[ "$SHARED_DISPATCH" == "true" ]] && upsert_eidolon_block "CLAUDE.md" "$SHARED_BLOCK"

        # Subagent dispatch — authoritative when claude-code is wired
        # Body conforms to EIIS v1.4 §4.2.6: references both agent.md and SPEC.md;
        # no legacy filenames (SPECTRA.md); no subdir-skill paths.
        if [[ "$DRY_RUN" != "true" ]]; then
          mkdir -p ".claude/agents"
          if [[ ! -f ".claude/agents/${EIDOLON_NAME}.md" || "$FORCE" == "true" ]]; then
            cat > ".claude/agents/${EIDOLON_NAME}.md" <<AGENT
---
name: ${EIDOLON_NAME}
description: "Decision-ready specifications — scoring rubrics, validation gates, GIVEN/WHEN/THEN stories."
model: opus
---

You are SPECTRA. Read these two files in order at session start:

1. \`./.eidolons/${EIDOLON_NAME}/agent.md\` — always-loaded P0 rules.
2. \`./.eidolons/${EIDOLON_NAME}/SPEC.md\` — deep on-demand methodology spec.

Skills live at \`./.eidolons/${EIDOLON_NAME}/skills/<skill>.md\` (load on demand).
AGENT
            FILES_WRITTEN+=(".claude/agents/${EIDOLON_NAME}.md|dispatch|created")
            FILES_WRITTEN_PATHS+=(".claude/agents/${EIDOLON_NAME}.md")
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
        [[ "$SHARED_DISPATCH" == "true" ]] && \
          upsert_eidolon_block ".github/copilot-instructions.md" "$SHARED_BLOCK"
        ;;

      cursor)
        HOSTS_WIRED+=("cursor")
        # Per-skill .cursor/rules/spectra-<skill>.mdc already emitted by wire_skill.
        # Drop the legacy methodology-level spectra.mdc on --force.
        if [[ -d ".cursor" || -f ".cursorrules" ]]; then
          [[ -f ".cursor/rules/${EIDOLON_NAME}.mdc" && "$FORCE" == "true" ]] && \
            rm -f ".cursor/rules/${EIDOLON_NAME}.mdc"
          :
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
Full spec:   \`${TARGET}/SPEC.md\`

SPECTRA produces specifications, never code. Activate for tasks with complexity ≥7/12."
          else
            log_info ".opencode/agents/${EIDOLON_NAME}.md already exists — use --force to overwrite"
          fi
        else
          log_warn "opencode host requested but no .opencode/ dir found — skipping dispatch file"
        fi
        ;;

      codex)
        HOSTS_WIRED+=("codex")
        # EIIS v1.1 §4.1.0 — root AGENTS.md is co-owned by `copilot` and
        # `codex`. When codex is wired we MUST own a marker-bounded block
        # there regardless of --shared-dispatch (it is Codex's primary
        # instruction surface). Skip if --shared-dispatch already handled
        # the AGENTS.md write above to avoid a duplicate manifest entry.
        if [[ "$SHARED_DISPATCH" != "true" ]]; then
          upsert_eidolon_block "AGENTS.md" "$SHARED_BLOCK"
        fi

        # EIIS v1.1 §4.5 — single Codex subagent file at .codex/agents/<name>.md.
        # Frontmatter contract: required `name` + `description`; optional
        # `tools` / `model`. Body mirrors the .claude/agents/spectra.md
        # subagent prompt — same conventions hook + path discipline so a
        # Codex invocation resolves to the same pipeline.
        # Source: https://developers.openai.com/codex/subagents
        if [[ "$DRY_RUN" != "true" ]]; then
          mkdir -p ".codex/agents"
          if [[ ! -f ".codex/agents/${EIDOLON_NAME}.md" || "$FORCE" == "true" ]]; then
            cat > ".codex/agents/${EIDOLON_NAME}.md" <<CODEX
---
name: ${EIDOLON_NAME}
description: Decision-ready specifications — scoring rubrics, validation gates, GIVEN/WHEN/THEN stories. Activate after a scout report or ATLAS map when you need a bounded, testable spec before implementation.
---

# SPECTRA — Codex subagent

SPECTRA runs the S→P→E→C→T→R→A cycle. Given an exploration or scout
report, it produces a spec with scoring rubrics, validation gates, and
structured stories that downstream implementers can act on without
ambiguity.

## On activation

1. Check for \`.spectra/setup/spectra-conventions.md\` in the current project. If it exists, read it — its project vocabulary (real module names, test framework, deploy targets, naming patterns) supersedes SPECTRA's generic placeholders ("FlowObject", "Repository") throughout the rest of the cycle. If absent, continue with generic defaults; conventions are optional enrichment.
2. Confirm the output target: every plan, spec, hypothesis, or state file you produce lands under \`.spectra/\` in this project — plans at \`.spectra/plans/\`, state at \`.spectra/state/\`, logs at \`.spectra/logs/\`. Never scatter files outside \`.spectra/\` without an explicit user request; even then, mirror a copy into \`.spectra/plans/\`.

## References

- \`${TARGET}/agent.md\` — P0 rules (read if deeper context is needed)
- \`${TARGET}/SPEC.md\` — full methodology specification
- \`${TARGET}/skills/planning.md\` — progressive-disclosure routing card
CODEX
            FILES_WRITTEN+=(".codex/agents/${EIDOLON_NAME}.md|dispatch|created")
            log_ok "Wrote: .codex/agents/${EIDOLON_NAME}.md"
          else
            log_info ".codex/agents/${EIDOLON_NAME}.md already exists — use --force to overwrite"
          fi
        else
          log_dry "write: .codex/agents/${EIDOLON_NAME}.md"
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

  # Build hosts_wired JSON array
  _hosts_json="["
  _first=true
  for _h in "${HOSTS_WIRED[@]+"${HOSTS_WIRED[@]}"}"; do
    [[ "$_first" == "true" ]] && _first=false || _hosts_json+=","
    _hosts_json+="\"${_h}\""
  done
  _hosts_json+="]"

  # Build skills[] JSON array (EIIS v1.3 §4.2.4 dual-write records).
  # source_path must match ^\.eidolons/<slug>/skills/<skill>.md
  # TARGET_REL strips any leading "./" so it is already ".eidolons/spectra".
  _skills_json="[]"
  _sk=""
  _add_skill() {
    local _name="$1"
    local _src_path="${TARGET_REL}/skills/${_name}.md"
    local _vendor_path=".claude/skills/${EIDOLON_NAME}-${_name}/SKILL.md"
    local _src_sha _vendor_sha
    _src_sha="$(sha256_of "${TARGET}/skills/${_name}.md" 2>/dev/null || echo "00000000")"
    if printf '%s\n' "${HOSTS}" | grep -q 'claude-code' && [[ -f "${_vendor_path}" ]]; then
      _vendor_sha="$(sha256_of "${_vendor_path}" 2>/dev/null || echo "00000000")"
      _sk+="{\"name\":\"${_name}\",\"source_path\":\"${_src_path}\",\"vendor_path\":\"${_vendor_path}\",\"source_sha256\":\"${_src_sha}\",\"vendor_sha256\":\"${_vendor_sha}\"},"
    else
      _sk+="{\"name\":\"${_name}\",\"source_path\":\"${_src_path}\",\"source_sha256\":\"${_src_sha}\"},"
    fi
  }
  _add_skill "planning"
  _skills_json="[${_sk%,}]"

  _installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "1970-01-01T00:00:00Z")

  # Canonical spec_file path (EIIS v1.3 §1.8) — schema pattern: ^\.eidolons/[a-z][a-z0-9-]*/SPEC\.md$
  # Always use the canonical relative form regardless of --target; strip any
  # leading './' or absolute prefix and rebuild from the eidolon name.
  _spec_file=".eidolons/${EIDOLON_NAME}/SPEC.md"

  # EIIS v1.4 §6.X — manifest-driven canonical-inventory sweep.
  # Add the manifest itself to the allow-set BEFORE sweeping so the sweep
  # does not attempt to remove the manifest file on idempotent runs.
  FILES_WRITTEN_PATHS+=("${MANIFEST_PATH}")
  canonical_inventory_sweep "${TARGET}"

  # Record the manifest in files_written[] so §1.7.4 is satisfied.
  _manifest_sha=$(sha256_of "${MANIFEST_PATH}" 2>/dev/null || echo "")
  FILES_WRITTEN+=("${MANIFEST_PATH}|manifest|created")

  # Rebuild files_written JSON (now includes manifest entry added above).
  _files_json="["
  _first=true
  for _entry in "${FILES_WRITTEN[@]+"${FILES_WRITTEN[@]}"}"; do
    IFS='|' read -r _fpath _frole _fmode <<< "$_entry"
    _fsha=$(sha256_of "$_fpath" 2>/dev/null || echo "")
    [[ "$_first" == "true" ]] && _first=false || _files_json+=","
    _files_json+="{\"path\":\"${_fpath}\",\"sha256\":\"${_fsha}\",\"role\":\"${_frole}\",\"mode\":\"${_fmode}\"}"
  done
  _files_json+="]"

  cat > "$MANIFEST_PATH" <<MANIFEST_EOF
{
  "eidolon": "${EIDOLON_NAME}",
  "version": "${EIDOLON_VERSION}",
  "methodology": "${METHODOLOGY}",
  "installed_at": "${_installed_at}",
  "target": "${TARGET}",
  "ecl_version_emitted": "${ECL_VERSION_EMITTED:-}",
  "spec_file": "${_spec_file}",
  "canonical_inventory_strict": true,
  "skills": ${_skills_json},
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
