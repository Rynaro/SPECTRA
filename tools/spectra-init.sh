#!/usr/bin/env bash
# spectra-init.sh — SPECTRA One-Hit Installer
#
# Analyzes a software project, detects the LLM vendor in use, and installs
# SPECTRA (the planning methodology) into your project in one pass.
#
# Usage:
#   bash spectra-init.sh                      # Analyze current directory
#   bash spectra-init.sh /path/to/project     # Analyze target project
#
# Outputs (in .spectra/setup/):
#   project-profile.md       — Detected project characteristics
#   adaptation-prompt.md     — Ready-to-paste LLM prompt
#
# Installs (vendor-specific location):
#   .claude/agents/spectra-planner.md         — Claude Code agent
#   .claude/skills/spectra-methodology/       — Claude Code skill
#   .cursor/rules/spectra-planner.mdc         — Cursor rules
#   .github/agents/spectra-planner.agent.md   — GitHub Copilot agent
#   .github/skills/spectra-methodologies/     — GitHub Copilot skill
#   .spectra/                                  — Vendor-neutral files
#
# Requirements: bash 4+, standard coreutils (find, grep, wc, sort, head)
# Tested on: Linux, macOS, WSL
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

set -euo pipefail

# ─── Script Location (must be first) ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECTRA_SOURCE_DIR="${SCRIPT_DIR}/../docs/spectra-methodology"

# ─── Configuration ────────────────────────────────────────────────────────────
SPECTRA_VERSION="4.2.0"
SPECTRA_REPO="https://github.com/Rynaro/SPECTRA"

# ─── Colors & TUI (with fallback for non-interactive) ───────────────────────
if [[ -t 1 ]]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
  BLUE='\033[0;34m'; CYAN='\033[0;36m'; MAGENTA='\033[0;35m'
  BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
  INTERACTIVE=1
else
  RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; MAGENTA=''
  BOLD=''; DIM=''; NC=''
  INTERACTIVE=0
fi

# ─── Global State ─────────────────────────────────────────────────────────────
SELECTED_VENDOR=""
SELECTED_MODE=""
INSTALLED_FILES=()
TARGET_DIR=""
PROJECT_ROOT=""
PROJECT_NAME=""

# ═════════════════════════════════════════════════════════════════════════════
# TUI FUNCTIONS
# ═════════════════════════════════════════════════════════════════════════════

tui_banner() {
  echo -e "${BOLD}${CYAN}"
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║   ✦ SPECTRA Installer v${SPECTRA_VERSION}                          ║"
  echo "║   Installing the planning methodology into your project  ║"
  echo "╚══════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo -e "  ${DIM}Project:${NC} ${BOLD}${PROJECT_NAME}${NC}"
  echo -e "  ${DIM}Root:${NC}    ${PROJECT_ROOT}"
  echo -e "  ${DIM}Vendor:${NC}  (auto-detecting...)"
  echo ""
}

tui_section() {
  echo ""
  echo -e "${BOLD}${MAGENTA}── $1 ──────────────────────────────────────${NC}"
  echo ""
}

tui_step() {
  echo -e "  ${BLUE}▸${NC} $1"
}

tui_ok() {
  echo -e "  ${GREEN}✓${NC} $1"
}

tui_warn() {
  echo -e "  ${YELLOW}⚠${NC} $1"
}

tui_info() {
  echo -e "  ${DIM}  $1${NC}"
}

tui_prompt() {
  local question="$1" default="$2"
  if [[ "$INTERACTIVE" -eq 1 ]]; then
    echo -e "  ${BOLD}${CYAN}?${NC} ${question} ${DIM}[default: ${default}]${NC}"
    printf "  → "
    read -r REPLY
    REPLY="${REPLY:-$default}"
  else
    REPLY="$default"
  fi
}

tui_menu() {
  local header="$1"; shift
  local opts=("$@")
  echo -e "  ${BOLD}${CYAN}?${NC} ${header}"
  local i=1
  for opt in "${opts[@]}"; do
    echo -e "    ${BOLD}${i})${NC} ${opt}"
    ((i++))
  done
  if [[ "$INTERACTIVE" -eq 1 ]]; then
    printf "  → "
    read -r MENU_CHOICE
    MENU_CHOICE="${MENU_CHOICE:-1}"
  else
    MENU_CHOICE=1
  fi
}

tui_summary_box() {
  echo ""
  echo -e "${BOLD}${GREEN}"
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║   ✓ SPECTRA Installed Successfully                       ║"
  echo "╚══════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo -e "  ${BOLD}Files installed:${NC}"
  for f in "$@"; do
    echo -e "    ${CYAN}${f#${TARGET_DIR}/}${NC}"
  done
  echo ""
  echo -e "  ${BOLD}Next steps:${NC}"
  echo -e "    1. Review ${CYAN}.spectra/conventions.md${NC} — fill in your project's conventions"
  echo -e "    2. Paste ${CYAN}.spectra/setup/adaptation-prompt.md${NC} into your LLM"
  echo -e "    3. Save the LLM output into ${CYAN}.spectra/conventions.md${NC}"
  echo -e "    4. Use ${CYAN}@spectra-planner${NC} or equivalent on your next feature"
  echo ""
  echo -e "  ${BOLD}Learn more:${NC} ${DIM}${SPECTRA_REPO}${NC}"
  echo ""
}

# ═════════════════════════════════════════════════════════════════════════════
# ARGUMENT HANDLING
# ═════════════════════════════════════════════════════════════════════════════

validate_args() {
  if [[ ! -d "$SPECTRA_SOURCE_DIR" ]]; then
    echo "ERROR: Cannot find SPECTRA source files at ${SPECTRA_SOURCE_DIR}" >&2
    echo "       Run spectra-init.sh from within the SPECTRA repository's tools/ directory." >&2
    exit 1
  fi

  if [[ $# -ge 1 && -d "$1" ]]; then
    TARGET_DIR="$(cd "$1" && pwd)"
  else
    TARGET_DIR="$(pwd)"
  fi

  PROJECT_ROOT="$TARGET_DIR"
  PROJECT_NAME="$(basename "$TARGET_DIR")"
}

# ═════════════════════════════════════════════════════════════════════════════
# DETECTION RULE ARRAYS (Data-Driven, Extensible)
# ═════════════════════════════════════════════════════════════════════════════

# Language detection: "LABEL:file_to_check"
declare -a LANG_FILE_RULES=(
  "Ruby:Gemfile"
  "JavaScript/TypeScript:package.json"
  "Go:go.mod"
  "Rust:Cargo.toml"
  "Elixir:mix.exs"
  "PHP:composer.json"
  "Swift:Package.swift"
  "Dart/Flutter:pubspec.yaml"
)

# Multi-file language rules: "LABEL:file1:file2:file3..."
declare -a LANG_MULTI_FILE_RULES=(
  "Python:requirements.txt:pyproject.toml:setup.py:Pipfile"
  "Java/Kotlin:pom.xml:build.gradle:build.gradle.kts"
)

# Framework detection: "LABEL:file:grep_pattern"
declare -a FRAMEWORK_GREP_RULES=(
  "Ruby on Rails:Gemfile:rails"
  "Sinatra:Gemfile:sinatra"
  "Hanami:Gemfile:hanami"
  "Next.js:package.json:\"next\""
  "Nuxt:package.json:\"nuxt\""
  "Express:package.json:\"express\""
  "Fastify:package.json:\"fastify\""
  "NestJS:package.json:\"@nestjs"
  "React:package.json:\"react\""
  "Vue:package.json:\"vue\""
  "Svelte:package.json:\"svelte\""
  "Angular:package.json:\"angular"
  "Remix:package.json:\"remix\""
  "Hono:package.json:\"hono\""
  "Django:requirements.txt:django"
  "Django:pyproject.toml:django"
  "Flask:requirements.txt:flask"
  "Flask:pyproject.toml:flask"
  "FastAPI:requirements.txt:fastapi"
  "FastAPI:pyproject.toml:fastapi"
  "Phoenix:mix.exs:phoenix"
  "Laravel:composer.json:laravel"
  "Go web framework:go.mod:gin-gonic\\|fiber\\|echo"
  "Rust web framework:Cargo.toml:actix\\|axum\\|rocket"
)

# Test framework detection: "LABEL:file:grep_pattern"
declare -a TEST_GREP_RULES=(
  "Jest:package.json:\"jest\""
  "Vitest:package.json:\"vitest\""
  "Mocha:package.json:\"mocha\""
  "Playwright:package.json:\"playwright\""
  "Cypress:package.json:\"cypress\""
  "pytest:pyproject.toml:pytest"
  "Minitest:Gemfile:minitest"
)

# Test framework detection by directory: "LABEL:dir"
declare -a TEST_DIR_RULES=(
  "RSpec:spec"
  "ExUnit:test"
)

# Build/package detection: "LABEL:file"
declare -a BUILD_FILE_RULES=(
  "Make:Makefile"
  "Docker:Dockerfile"
  "Docker:docker-compose.yml"
  "Docker:docker-compose.yaml"
  "npm:package-lock.json"
  "Yarn:yarn.lock"
  "pnpm:pnpm-lock.yaml"
  "Bun:bun.lockb"
  "Bundler:Gemfile.lock"
  "Poetry:poetry.lock"
  "Cargo:Cargo.lock"
  "Go modules:go.sum"
)

# CI detection by directory: "LABEL:dir"
declare -a CI_DIR_RULES=(
  "GitHub Actions:.github/workflows"
)

# CI detection by file: "LABEL:file"
declare -a CI_FILE_RULES=(
  "GitLab CI:.gitlab-ci.yml"
  "CircleCI:.circleci/config.yml"
  "Jenkins:Jenkinsfile"
)

# Database detection: "LABEL:file:grep_pattern"
declare -a DB_GREP_RULES=(
  "PostgreSQL:config/database.yml:postgres"
  "MySQL:config/database.yml:mysql"
  "SQLite:config/database.yml:sqlite"
  "Prisma:package.json:\"prisma\""
  "MongoDB:package.json:\"mongoose\""
  "TypeORM:package.json:\"typeorm\""
  "Drizzle:package.json:\"drizzle\""
)

# Architecture detection by directory: "LABEL:dir1:dir2:..." (checks if ALL dirs exist)
declare -a ARCH_DIR_RULES=(
  "MVC:app/models:app/controllers"
  "Service Layer:app/services"
  "Service Layer:src/services"
  "Background Jobs:app/jobs"
  "Background Jobs:app/workers"
  "Policy Objects:app/policies"
  "Repository Pattern:src/repositories"
  "Repository Pattern:src/repo"
  "Middleware:src/middleware"
  "DTOs/Schemas:src/dto"
  "DTOs/Schemas:src/schemas"
  "Domain Entities:src/domain"
  "Domain Entities:src/entities"
  "Event-Driven:src/events"
  "Event-Driven:app/events"
)

# ═════════════════════════════════════════════════════════════════════════════
# REFACTORED DETECTION FUNCTIONS (Rule Array-Based)
# ═════════════════════════════════════════════════════════════════════════════

detect_languages() {
  local langs=""

  # Single-file rules
  for rule in "${LANG_FILE_RULES[@]}"; do
    local label="${rule%%:*}" file="${rule#*:}"
    [[ -f "$TARGET_DIR/$file" ]] && langs="${langs}${label}, "
  done

  # Multi-file rules
  for rule in "${LANG_MULTI_FILE_RULES[@]}"; do
    local label="${rule%%:*}"
    local files_part="${rule#*:}"
    IFS=':' read -ra files <<< "$files_part"
    local found=0
    for f in "${files[@]}"; do
      [[ -f "$TARGET_DIR/$f" ]] && found=1 && break
    done
    [[ $found -eq 1 ]] && langs="${langs}${label}, "
  done

  # C#/.NET glob fallback
  find "$TARGET_DIR" -maxdepth 1 \( -name "*.csproj" -o -name "*.sln" \) 2>/dev/null | head -1 | grep -q . && langs="${langs}C#/.NET, "

  # Extension-based fallback
  if [[ -z "$langs" ]]; then
    langs=$(find "$TARGET_DIR" -maxdepth 4 -type f \( -name "*.rb" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \
      -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.kt" -o -name "*.cs" \
      -o -name "*.ex" -o -name "*.php" -o -name "*.swift" \) 2>/dev/null | \
      sed 's/.*\.//' | sort | uniq -c | sort -rn | head -3 | awk '{print $2}' | tr '\n' ', ')
  fi
  echo "${langs%, }" | sed 's/^$/Unknown/'
}

detect_framework() {
  local fw=""
  for rule in "${FRAMEWORK_GREP_RULES[@]}"; do
    local label file pattern
    label=$(echo "$rule" | cut -d: -f1)
    file=$(echo "$rule"  | cut -d: -f2)
    pattern=$(echo "$rule" | cut -d: -f3-)
    [[ -f "$TARGET_DIR/$file" ]] && grep -qi "$pattern" "$TARGET_DIR/$file" 2>/dev/null && fw="${fw}${label}, "
  done
  echo "${fw%, }" | sed 's/^$/Not detected/'
}

detect_test_framework() {
  local tf=""

  # Directory-based rules
  for rule in "${TEST_DIR_RULES[@]}"; do
    local label="${rule%%:*}" dir="${rule#*:}"
    [[ -d "$TARGET_DIR/$dir" ]] && tf="${tf}${label}, "
  done

  # Grep-based rules
  for rule in "${TEST_GREP_RULES[@]}"; do
    local label file pattern
    label=$(echo "$rule" | cut -d: -f1)
    file=$(echo "$rule"  | cut -d: -f2)
    pattern=$(echo "$rule" | cut -d: -f3-)
    [[ -f "$TARGET_DIR/$file" ]] && grep -qi "$pattern" "$TARGET_DIR/$file" 2>/dev/null && tf="${tf}${label}, "
  done

  # Go testing (special case)
  find "$TARGET_DIR" -maxdepth 3 -name "*_test.go" 2>/dev/null | head -1 | grep -q . && tf="${tf}Go testing, "

  # Rust testing (special case)
  grep -rq "#\[cfg(test)\]" "$TARGET_DIR" --include="*.rs" 2>/dev/null && tf="${tf}Rust tests, "

  echo "${tf%, }" | sed 's/^$/Not detected/'
}

detect_build_and_package() {
  local bp=""
  for rule in "${BUILD_FILE_RULES[@]}"; do
    local label="${rule%%:*}" file="${rule#*:}"
    [[ -f "$TARGET_DIR/$file" ]] && bp="${bp}${label}, "
  done
  echo "${bp%, }" | sed 's/^$/Not detected/'
}

detect_ci() {
  local ci=""

  # Directory-based rules
  for rule in "${CI_DIR_RULES[@]}"; do
    local label="${rule%%:*}" dir="${rule#*:}"
    [[ -d "$TARGET_DIR/$dir" ]] && ci="${ci}${label}, "
  done

  # File-based rules
  for rule in "${CI_FILE_RULES[@]}"; do
    local label="${rule%%:*}" file="${rule#*:}"
    [[ -f "$TARGET_DIR/$file" ]] && ci="${ci}${label}, "
  done

  echo "${ci%, }" | sed 's/^$/Not detected/'
}

detect_db() {
  local db=""

  # Grep-based rules
  for rule in "${DB_GREP_RULES[@]}"; do
    local label file pattern
    label=$(echo "$rule" | cut -d: -f1)
    file=$(echo "$rule"  | cut -d: -f2)
    pattern=$(echo "$rule" | cut -d: -f3-)
    [[ -f "$TARGET_DIR/$file" ]] && grep -qi "$pattern" "$TARGET_DIR/$file" 2>/dev/null && db="${db}${label}, "
  done

  # Redis special case
  grep -rq "redis" "$TARGET_DIR" --include="Gemfile" --include="package.json" --include="requirements.txt" 2>/dev/null && db="${db}Redis, "

  echo "${db%, }" | sed 's/^$/Not detected/'
}

detect_architecture() {
  local pat=""

  # Multi-directory rules (all dirs must exist)
  for rule in "${ARCH_DIR_RULES[@]}"; do
    local label="${rule%%:*}"
    local dirs_part="${rule#*:}"
    IFS=':' read -ra dirs <<< "$dirs_part"
    local all_exist=1
    for d in "${dirs[@]}"; do
      [[ -d "$TARGET_DIR/$d" ]] || all_exist=0
    done
    [[ $all_exist -eq 1 ]] && pat="${pat}${label}, "
  done

  echo "${pat%, }" | sed 's/^$/Not detected/'
}

get_dir_tree() {
  find "$TARGET_DIR" -maxdepth 3 -type d \
    -not -path '*/\.*' -not -path '*/node_modules*' -not -path '*/vendor*' \
    -not -path '*/__pycache__*' -not -path '*/target*' -not -path '*/dist*' \
    -not -path '*/build*' -not -path '*/.next*' -not -path '*/tmp*' \
    -not -path '*/log*' -not -path '*/coverage*' \
    2>/dev/null | sort | head -50 | sed 's|^'"$TARGET_DIR"'/||' | sed 's|^'"$TARGET_DIR"'$|.|'
}

get_naming_samples() {
  find "$TARGET_DIR" -maxdepth 4 -type f \( -name "*.rb" -o -name "*.py" -o -name "*.ts" -o -name "*.js" \
    -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.kt" -o -name "*.ex" -o -name "*.php" \) \
    -not -path '*/test*' -not -path '*/spec*' -not -path '*/node_modules*' -not -path '*/vendor*' \
    2>/dev/null | head -15 | sed 's|^'"$TARGET_DIR"'/||' | sort
}

get_project_docs() {
  local docs=""
  [[ -f "$TARGET_DIR/README.md" || -f "$TARGET_DIR/README.rst" ]] && docs="${docs}README, "
  [[ -f "$TARGET_DIR/ARCHITECTURE.md" || -d "$TARGET_DIR/docs/adr" ]] && docs="${docs}Architecture docs, "
  [[ -f "$TARGET_DIR/.cursorrules" || -d "$TARGET_DIR/.cursor/rules" ]] && docs="${docs}Cursor rules, "
  [[ -f "$TARGET_DIR/CLAUDE.md" ]] && docs="${docs}Claude config, "
  [[ -f "$TARGET_DIR/AGENTS.md" ]] && docs="${docs}AGENTS.md, "
  [[ -f "$TARGET_DIR/.github/copilot-instructions.md" ]] && docs="${docs}Copilot instructions, "
  [[ -f "$TARGET_DIR/spectra-conventions.md" ]] && docs="${docs}SPECTRA conventions, "
  echo "${docs%, }" | sed 's/^$/None/'
}

get_convention_summary() {
  local summary=""
  local convention_files=(.cursorrules CLAUDE.md AGENTS.md .github/copilot-instructions.md ARCHITECTURE.md)
  for cf in "${convention_files[@]}"; do
    if [[ -f "$TARGET_DIR/$cf" ]]; then
      local lines
      lines=$(wc -l < "$TARGET_DIR/$cf" 2>/dev/null | tr -d ' ')
      summary="${summary}- **${cf}** (${lines} lines)\n"
    fi
  done
  if [[ -d "$TARGET_DIR/.cursor/rules" ]]; then
    local count
    count=$(find "$TARGET_DIR/.cursor/rules" -name "*.mdc" 2>/dev/null | wc -l | tr -d ' ')
    [[ "$count" -gt 0 ]] && summary="${summary}- **.cursor/rules/** (${count} .mdc files)\n"
  fi
  if [[ -d "$TARGET_DIR/docs/adr" ]]; then
    local count
    count=$(find "$TARGET_DIR/docs/adr" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    [[ "$count" -gt 0 ]] && summary="${summary}- **docs/adr/** (${count} ADRs)\n"
  fi
  echo -e "${summary:-None detected}"
}

get_file_count() {
  find "$TARGET_DIR" -type f -not -path '*/\.*' -not -path '*/node_modules*' \
    -not -path '*/vendor*' -not -path '*/target*' 2>/dev/null | wc -l | tr -d ' '
}

# ═════════════════════════════════════════════════════════════════════════════
# VENDOR DETECTION
# ═════════════════════════════════════════════════════════════════════════════

declare -a VENDOR_KEYS=(claude copilot cursor generic)
declare -a VENDOR_NAMES=("Claude Code" "GitHub Copilot" "Cursor" "Generic / AGENTS.md")

detect_vendor_claude() {
  [[ -d "${TARGET_DIR}/.claude" ]]
}

detect_vendor_copilot() {
  [[ -f "${TARGET_DIR}/.github/copilot-instructions.md" ]]
}

detect_vendor_cursor() {
  [[ -d "${TARGET_DIR}/.cursor/rules" ]] || [[ -f "${TARGET_DIR}/.cursorrules" ]]
}

detect_vendor_generic() {
  [[ -f "${TARGET_DIR}/AGENTS.md" ]]
}

_vendor_ask_user() {
  local candidates=("${@:-${VENDOR_KEYS[@]}}")
  local display_names=()
  for key in "${candidates[@]}"; do
    local idx=0
    for i in "${!VENDOR_KEYS[@]}"; do
      [[ "${VENDOR_KEYS[$i]}" = "$key" ]] && idx=$i && break
    done
    display_names+=("${VENDOR_NAMES[$idx]}")
  done
  tui_menu "Which LLM tool does this project use?" "${display_names[@]}"
  local idx=$(( MENU_CHOICE - 1 ))
  SELECTED_VENDOR="${candidates[$idx]}"
  # Find index of SELECTED_VENDOR in VENDOR_KEYS for display
  for i in "${!VENDOR_KEYS[@]}"; do
    [[ "${VENDOR_KEYS[$i]}" = "$SELECTED_VENDOR" ]] && tui_ok "Selected: ${VENDOR_NAMES[$i]}" && break
  done
}

run_vendor_detection() {
  tui_section "LLM Vendor Detection"
  local detected=()

  for key in "${VENDOR_KEYS[@]}"; do
    local key_idx=0
    for i in "${!VENDOR_KEYS[@]}"; do
      [[ "${VENDOR_KEYS[$i]}" = "$key" ]] && key_idx=$i && break
    done
    tui_step "Checking for ${VENDOR_NAMES[$key_idx]}..."
    if "detect_vendor_${key}"; then
      tui_ok "Detected: ${VENDOR_NAMES[$key_idx]}"
      detected+=("$key")
    fi
  done

  if [[ ${#detected[@]} -eq 1 ]]; then
    SELECTED_VENDOR="${detected[0]}"
    local idx=0
    for i in "${!VENDOR_KEYS[@]}"; do
      [[ "${VENDOR_KEYS[$i]}" = "$SELECTED_VENDOR" ]] && idx=$i && break
    done
    tui_ok "Auto-selected vendor: ${VENDOR_NAMES[$idx]}"
  elif [[ ${#detected[@]} -eq 0 ]]; then
    tui_warn "No vendor configuration detected. Using default."
    _vendor_ask_user "${VENDOR_KEYS[@]}"
  else
    tui_warn "Multiple vendors detected. Please choose one."
    _vendor_ask_user "${detected[@]}"
  fi
}

# ═════════════════════════════════════════════════════════════════════════════
# MODE SELECTION
# ═════════════════════════════════════════════════════════════════════════════

run_mode_selection() {
  tui_section "Installation Mode"
  echo -e "  ${DIM}Agent — full methodology, lives in vendor's agents directory${NC}"
  echo -e "  ${DIM}Skill  — quick-reference card, lives in vendor's skills directory${NC}"
  echo ""
  tui_menu "Install SPECTRA as:" "Agent (recommended)" "Skill"
  case "$MENU_CHOICE" in
    1) SELECTED_MODE="agent" ;;
    2) SELECTED_MODE="skill" ;;
    *) SELECTED_MODE="agent" ;;
  esac
  tui_ok "Mode: ${SELECTED_MODE}"
}

# ═════════════════════════════════════════════════════════════════════════════
# FILE INSTALLATION HELPERS
# ═════════════════════════════════════════════════════════════════════════════

install_ensure_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || mkdir -p "$dir"
}

install_copy_with_frontmatter() {
  local src="$1" dest="$2" frontmatter="$3"
  install_ensure_dir "$(dirname "$dest")"
  {
    printf -- "---\n"
    printf "%s\n" "$frontmatter"
    printf -- "---\n\n"
    cat "$src"
  } > "$dest"
  tui_ok "Installed: ${dest#${TARGET_DIR}/}"
  INSTALLED_FILES+=("$dest")
}

install_copy_plain() {
  local src="$1" dest="$2"
  install_ensure_dir "$(dirname "$dest")"
  cp "$src" "$dest"
  tui_ok "Installed: ${dest#${TARGET_DIR}/}"
  INSTALLED_FILES+=("$dest")
}

# ═════════════════════════════════════════════════════════════════════════════
# VENDOR-SPECIFIC INSTALLATION
# ═════════════════════════════════════════════════════════════════════════════

install_vendor_claude() {
  tui_section "Installing for Claude Code"

  if [[ "$SELECTED_MODE" == "agent" ]]; then
    local dest="${TARGET_DIR}/.claude/agents/spectra-planner.md"
    if [[ -f "$dest" ]]; then
      tui_warn "Agent already installed at .claude/agents/spectra-planner.md"
      return
    fi
    local fm="name: spectra-planner
description: >-
  SPECTRA planning specialist. Use this agent to plan complex features,
  multi-component changes, or any task where complexity is >=7/12.
  Invoke with @spectra-planner followed by your feature description.
model: inherit
color: purple
tools: [\"Read\", \"Grep\", \"Glob\"]"
    install_copy_with_frontmatter "${SPECTRA_SOURCE_DIR}/SPECTRA.md" "$dest" "$fm"
  else
    # Skill mode
    local skill_dir="${TARGET_DIR}/.claude/skills/spectra-methodology"
    if [[ -d "$skill_dir" ]]; then
      tui_warn "Skill already installed at .claude/skills/spectra-methodology/"
      return
    fi
    local fm_skill="name: spectra-methodology
description: \"SPECTRA v${SPECTRA_VERSION} — vendor-agnostic specification and planning methodology for AI agents.\"
metadata:
  version: ${SPECTRA_VERSION}"
    install_copy_with_frontmatter "${SPECTRA_SOURCE_DIR}/SKILL.md"   "${skill_dir}/SKILL.md"   "$fm_skill"
    install_copy_plain "${SPECTRA_SOURCE_DIR}/SPECTRA.md"   "${skill_dir}/SPECTRA.md"
    install_copy_plain "${SPECTRA_SOURCE_DIR}/scoring.md"   "${skill_dir}/resources/scoring.md"
    install_copy_plain "${SPECTRA_SOURCE_DIR}/templates.md" "${skill_dir}/resources/templates.md"
  fi
}

install_vendor_copilot() {
  tui_section "Installing for GitHub Copilot"

  if [[ "$SELECTED_MODE" == "agent" ]]; then
    local dest="${TARGET_DIR}/.github/agents/spectra-planner.agent.md"
    if [[ -f "$dest" ]]; then
      tui_warn "Agent already installed at .github/agents/spectra-planner.agent.md"
      return
    fi
    local fm="# Copilot custom agent file
name: spectra-planner
description: SPECTRA planning specialist for AI-assisted feature specification.
version: ${SPECTRA_VERSION}"
    install_copy_with_frontmatter "${SPECTRA_SOURCE_DIR}/SPECTRA.md" "$dest" "$fm"
  else
    # Skill mode
    local skill_dir="${TARGET_DIR}/.github/skills/spectra-methodologies"
    if [[ -d "$skill_dir" ]]; then
      tui_warn "Skill already installed at .github/skills/spectra-methodologies/"
      return
    fi
    local fm_skill="name: spectra-methodology
description: \"SPECTRA v${SPECTRA_VERSION} — planning methodology for AI agents.\""
    install_copy_with_frontmatter "${SPECTRA_SOURCE_DIR}/SKILL.md"   "${skill_dir}/SKILL.md"   "$fm_skill"
    install_copy_plain "${SPECTRA_SOURCE_DIR}/SPECTRA.md"   "${skill_dir}/SPECTRA.md"
    install_copy_plain "${SPECTRA_SOURCE_DIR}/scoring.md"   "${skill_dir}/resources/scoring.md"
    install_copy_plain "${SPECTRA_SOURCE_DIR}/templates.md" "${skill_dir}/resources/templates.md"
  fi
}

install_vendor_cursor() {
  tui_section "Installing for Cursor"

  local dest="${TARGET_DIR}/.cursor/rules/spectra-planner.mdc"
  if [[ -f "$dest" ]]; then
    tui_warn "Already installed at .cursor/rules/spectra-planner.mdc"
    return
  fi

  if [[ "$SELECTED_MODE" == "agent" ]]; then
    local fm="description: SPECTRA planning specialist. Use for complex features (complexity >=7/12).
globs: [\"**/*.md\", \"**/*.yaml\", \"**/*.json\"]
alwaysApply: false"
    install_copy_with_frontmatter "${SPECTRA_SOURCE_DIR}/SPECTRA.md" "$dest" "$fm"
  else
    local fm="description: SPECTRA quick-reference planning card.
globs: []
alwaysApply: false"
    install_copy_with_frontmatter "${SPECTRA_SOURCE_DIR}/SKILL.md" "$dest" "$fm"
  fi
}

install_vendor_generic() {
  tui_section "Installing (Generic / AGENTS.md layout)"

  local dest="${TARGET_DIR}/.spectra/spectra-planner.md"
  if [[ -f "$dest" ]]; then
    tui_warn "Already installed at .spectra/spectra-planner.md"
    return
  fi
  install_copy_plain "${SPECTRA_SOURCE_DIR}/SPECTRA.md" "$dest"
}

# ═════════════════════════════════════════════════════════════════════════════
# .SPECTRA/ STRUCTURE & REPORT GENERATION
# ═════════════════════════════════════════════════════════════════════════════

_write_conventions_stub() {
  local dest="$1"
  cat > "$dest" << EOF
# SPECTRA Conventions — ${PROJECT_NAME}

> This file is a stub. Generate your project's conventions by pasting
> \`.spectra/setup/adaptation-prompt.md\` into your preferred LLM.
>
> Then replace this file with the output.

## SPECTRA Files

| Resource | Path |
|----------|------|
| This conventions file | \`.spectra/conventions.md\` |
| Methodology | \`.spectra/spectra-planner.md\` |
| Plans directory | \`.spectra/plans/\` |
| Project profile | \`.spectra/setup/project-profile.md\` |

*Generated by SPECTRA v${SPECTRA_VERSION} — ${SPECTRA_REPO}*
EOF
}

_write_project_profile() {
  local dest="$1"
  cat > "$dest" << EOF
# SPECTRA Project Profile

> Generated by spectra-init.sh v${SPECTRA_VERSION} on $(date -u +%Y-%m-%d)
> Project: **${PROJECT_NAME}**

## Stack

| Aspect | Detected |
|--------|----------|
| Languages | ${LANGUAGES} |
| Frameworks | ${FRAMEWORKS} |
| Test Frameworks | ${TEST_FW} |
| Build / Package | ${BUILD_TOOLS} |
| CI/CD | ${CI_SYSTEM} |
| Database | ${DATABASE} |
| Architecture | ${ARCH_PATTERNS} |
| Files | ~${FILE_COUNT} |
| Existing Docs | ${PROJECT_DOCS} |

## Convention Files Detected

${CONVENTION_SUMMARY}

## Directory Structure (top 3 levels)

\`\`\`
${DIR_TREE}
\`\`\`

## Naming Samples

\`\`\`
${NAMING_SAMPLES}
\`\`\`

## Next Step

Paste **adaptation-prompt.md** into your preferred LLM to generate SPECTRA conventions for this project.

*SPECTRA v${SPECTRA_VERSION} — ${SPECTRA_REPO}*
EOF
}

_write_adaptation_prompt() {
  local dest="$1"
  # Determine vendor invocation hint
  local vendor_hint=""
  case "$SELECTED_VENDOR" in
    claude)
      vendor_hint="Then save the output as **\`.spectra/conventions.md\`** and invoke SPECTRA with **\`@spectra-planner\`** in chat."
      ;;
    copilot)
      vendor_hint="Then save the output as **\`.spectra/conventions.md\`** and invoke the \`spectra-planner\` agent via Copilot's agent menu."
      ;;
    cursor)
      vendor_hint="Then save the output as **\`.spectra/conventions.md\`** and Cursor will automatically apply SPECTRA rules when you edit."
      ;;
    *)
      vendor_hint="Then save the output as **\`.spectra/conventions.md\`** and reference it in your LLM setup."
      ;;
  esac

  cat > "$dest" << EOF
# SPECTRA Stack Adaptation Prompt

> Copy this entire file and paste into your preferred LLM (Claude, GPT, Gemini, Llama, etc.).
> It will generate a conventions file mapping SPECTRA's generic vocabulary to your project.

---

## Context

I'm adopting **SPECTRA** (${SPECTRA_REPO}), a vendor-agnostic planning methodology for AI-assisted software specification. SPECTRA uses generic terminology (Service Objects, Repository Pattern, etc.). I need you to map these concepts to my project's specific conventions so that SPECTRA-generated specs use the right vocabulary for my codebase.

## My Project

| Aspect | Value |
|--------|-------|
| Project | ${PROJECT_NAME} |
| Languages | ${LANGUAGES} |
| Frameworks | ${FRAMEWORKS} |
| Tests | ${TEST_FW} |
| Build | ${BUILD_TOOLS} |
| CI/CD | ${CI_SYSTEM} |
| Database | ${DATABASE} |
| Architecture | ${ARCH_PATTERNS} |

### Directory Structure
\`\`\`
${DIR_TREE}
\`\`\`

### Naming Samples
\`\`\`
${NAMING_SAMPLES}
\`\`\`

## Generate These Sections

### 1. Convention Mapping

Map SPECTRA generic concepts to my project. Fill "My Convention" and "Path Pattern":

| SPECTRA Concept | Generic Example | My Convention | Path Pattern |
|----------------|-----------------|---------------|--------------|
| Service / Business Logic | \`UserRegistrationService\` | ? | ? |
| Data Access / Repository | \`UserRepository\` | ? | ? |
| Schema / Validation | \`UserSchema\` | ? | ? |
| UI Component | \`UserProfile\` | ? | ? |
| Background Job | \`ImportJob\` | ? | ? |
| API Endpoint | \`POST /users\` | ? | ? |
| Database Migration | \`add_users_table\` | ? | ? |
| Test File | \`user.test.ts\` | ? | ? |

### 2. Action Verb Mapping

SPECTRA stories use verbs: Create, Extend, Modify, Test, Configure, Migrate. Map each to my stack:

| Verb | In My Project | Example |
|------|--------------|---------|
| Create | ? | "Create \`?\` at \`?\`" |
| Extend | ? | "Extend \`?\` with \`?\`" |
| Modify | ? | "Modify \`?\` to \`?\`" |
| Test | ? | "Test with \`?\` covering \`?\`" |
| Configure | ? | "Configure \`?\` in \`?\`" |
| Migrate | ? | "Migrate \`?\` using \`?\`" |

### 3. Validation Gates Template

Standard P0/P1/P2 gates for my project:

\`\`\`markdown
## Agent Hints:
- **Class:** [builder/reasoner/debugger]
- **Context:** [path to exemplar]
- **Gates:**
  - [ ] P0: [my critical gate, e.g., "no direct DB outside repository"]
  - [ ] P1: [my test gate, e.g., "≥90% coverage"]
  - [ ] P2: [my lint gate, e.g., "linter passes clean"]
\`\`\`

### 4. Example Story

Write a complete SPECTRA story for: **"Add a health check endpoint returning service status and version"** using my project's actual conventions, paths, and patterns. Follow this format:

\`\`\`markdown
#### STORY: S-1 [Title]
Description: As a [ACTOR], I want [CAPABILITY] so that [VALUE]
Timebox: [duration]
Action Plan: [numbered steps with verbs]
Acceptance Criteria: [GIVEN/WHEN/THEN]
Technical Context: [pattern, files, deps]
Agent Hints: [class, context, gates]
\`\`\`

### 5. Project-Specific Rules

Based on my architecture, what constraints should every SPECTRA spec follow? Cover:
- Naming conventions
- Architectural boundaries (e.g., "no logic in controllers")
- Test requirements
- Deployment constraints

### 6. Artifact Storage

Where should SPECTRA store planning artifacts in my project?

\`\`\`
[project_root]/
├── [plans_dir]/           # .md, .yaml, .state.json
├── [patterns_dir]/        # Reusable patterns
└── [conventions_file]     # This conventions file
\`\`\`

## Output

Single Markdown file: \`spectra-conventions.md\`

Start with a **Quick Reference** (5 most important conventions for this project), then all sections above.

## Next

${vendor_hint}

*Prompt generated by SPECTRA v${SPECTRA_VERSION}*
EOF
}

install_spectra_structure() {
  tui_section "Installing .spectra/ Structure"

  local spectra_dir="${TARGET_DIR}/.spectra"
  install_ensure_dir "${spectra_dir}/plans"
  install_ensure_dir "${spectra_dir}/setup"

  # Conventions stub — only create if not exists
  local conventions="${spectra_dir}/conventions.md"
  if [[ ! -f "$conventions" ]]; then
    _write_conventions_stub "$conventions"
    tui_ok "Created: .spectra/conventions.md (stub)"
    INSTALLED_FILES+=("$conventions")
  else
    tui_info "Skipped: .spectra/conventions.md already exists"
  fi

  # Generate project profile and adaptation prompt
  _write_project_profile "${spectra_dir}/setup/project-profile.md"
  _write_adaptation_prompt "${spectra_dir}/setup/adaptation-prompt.md"
  INSTALLED_FILES+=("${spectra_dir}/setup/project-profile.md" "${spectra_dir}/setup/adaptation-prompt.md")
}

run_installation() {
  "install_vendor_${SELECTED_VENDOR}"
  install_spectra_structure
}

# ═════════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═════════════════════════════════════════════════════════════════════════════

validate_args "$@"
tui_banner

# Run detection with progress indicators
tui_section "Project Discovery"
tui_step "Detecting languages..."
LANGUAGES=$(detect_languages)
tui_ok "Languages: ${LANGUAGES}"

tui_step "Detecting frameworks..."
FRAMEWORKS=$(detect_framework)
tui_ok "Frameworks: ${FRAMEWORKS}"

tui_step "Detecting test frameworks..."
TEST_FW=$(detect_test_framework)
tui_ok "Test frameworks: ${TEST_FW}"

tui_step "Detecting build tools..."
BUILD_TOOLS=$(detect_build_and_package)
tui_ok "Build tools: ${BUILD_TOOLS}"

tui_step "Detecting CI/CD..."
CI_SYSTEM=$(detect_ci)
tui_ok "CI/CD: ${CI_SYSTEM}"

tui_step "Detecting databases..."
DATABASE=$(detect_db)
tui_ok "Databases: ${DATABASE}"

tui_step "Detecting architecture..."
ARCH_PATTERNS=$(detect_architecture)
tui_ok "Architecture: ${ARCH_PATTERNS}"

tui_step "Scanning structure and conventions..."
DIR_TREE=$(get_dir_tree)
NAMING_SAMPLES=$(get_naming_samples)
PROJECT_DOCS=$(get_project_docs)
CONVENTION_SUMMARY=$(get_convention_summary)
FILE_COUNT=$(get_file_count)
tui_ok "Scan complete"

# Vendor detection and mode selection
run_vendor_detection
run_mode_selection

# Installation
run_installation

# Summary
tui_summary_box "${INSTALLED_FILES[@]}"
