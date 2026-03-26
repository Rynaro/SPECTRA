#!/usr/bin/env bash
# spectra-init.sh — SPECTRA Project Analyzer & Adaptation Prompt Generator
#
# Analyzes any software project and generates an LLM prompt to create
# SPECTRA-compatible conventions for your specific stack.
#
# Usage:
#   cd /path/to/your/project && bash spectra-init.sh
#   # or:
#   bash spectra-init.sh /path/to/your/project
#
# Outputs (in project root):
#   spectra-project-profile.md     — Detected project characteristics
#   spectra-adaptation-prompt.md   — Ready-to-paste LLM prompt
#
# Requirements: bash 4+, standard coreutils (find, grep, wc, sort, head)
# Tested on: Linux, macOS, WSL
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

set -euo pipefail

# ─── Colors (with fallback for non-interactive) ──────────────────────────────
if [[ -t 1 ]]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
  BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; BOLD=''; NC=''
fi

# ─── Configuration ────────────────────────────────────────────────────────────
PROFILE_OUT="spectra-project-profile.md"
PROMPT_OUT="spectra-adaptation-prompt.md"
SPECTRA_VERSION="4.2.0"
SPECTRA_REPO="https://github.com/Rynaro/SPECTRA"

# ─── Navigate to project root ─────────────────────────────────────────────────
if [[ $# -ge 1 && -d "$1" ]]; then
  cd "$1"
fi

PROJECT_ROOT="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"

echo -e "${BOLD}${CYAN}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║   SPECTRA Project Analyzer v${SPECTRA_VERSION}         ║"
echo "║   Analyzing project for SPECTRA adaptation...          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${GREEN}▸${NC} Project: ${BOLD}${PROJECT_NAME}${NC}"
echo -e "${GREEN}▸${NC} Root:    ${PROJECT_ROOT}"
echo ""

# ─── Detection Functions ──────────────────────────────────────────────────────

detect_languages() {
  local langs=""
  [[ -f "Gemfile" ]] && langs="${langs}Ruby, "
  [[ -f "package.json" ]] && langs="${langs}JavaScript/TypeScript, "
  [[ -f "requirements.txt" || -f "pyproject.toml" || -f "setup.py" || -f "Pipfile" ]] && langs="${langs}Python, "
  [[ -f "go.mod" ]] && langs="${langs}Go, "
  [[ -f "Cargo.toml" ]] && langs="${langs}Rust, "
  [[ -f "pom.xml" || -f "build.gradle" || -f "build.gradle.kts" ]] && langs="${langs}Java/Kotlin, "
  [[ -f "mix.exs" ]] && langs="${langs}Elixir, "
  [[ -f "composer.json" ]] && langs="${langs}PHP, "
  [[ -f "Package.swift" ]] && langs="${langs}Swift, "
  [[ -f "pubspec.yaml" ]] && langs="${langs}Dart/Flutter, "
  find . -maxdepth 1 -name "*.csproj" -o -name "*.sln" 2>/dev/null | head -1 | grep -q . && langs="${langs}C#/.NET, "
  if [[ -z "$langs" ]]; then
    langs=$(find . -maxdepth 4 -type f \( -name "*.rb" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \
      -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.kt" -o -name "*.cs" \
      -o -name "*.ex" -o -name "*.php" -o -name "*.swift" \) 2>/dev/null | \
      sed 's/.*\.//' | sort | uniq -c | sort -rn | head -3 | awk '{print $2}' | tr '\n' ', ')
  fi
  echo "${langs%, }" | sed 's/^$/Unknown/'
}

detect_framework() {
  local fw=""
  if [[ -f "Gemfile" ]]; then
    grep -qi "rails" Gemfile 2>/dev/null && fw="${fw}Ruby on Rails, "
    grep -qi "sinatra" Gemfile 2>/dev/null && fw="${fw}Sinatra, "
    grep -qi "hanami" Gemfile 2>/dev/null && fw="${fw}Hanami, "
  fi
  if [[ -f "package.json" ]]; then
    grep -qi '"next"' package.json 2>/dev/null && fw="${fw}Next.js, "
    grep -qi '"nuxt"' package.json 2>/dev/null && fw="${fw}Nuxt, "
    grep -qi '"express"' package.json 2>/dev/null && fw="${fw}Express, "
    grep -qi '"fastify"' package.json 2>/dev/null && fw="${fw}Fastify, "
    grep -qi '"@nestjs' package.json 2>/dev/null && fw="${fw}NestJS, "
    grep -qi '"react"' package.json 2>/dev/null && fw="${fw}React, "
    grep -qi '"vue"' package.json 2>/dev/null && fw="${fw}Vue, "
    grep -qi '"svelte"' package.json 2>/dev/null && fw="${fw}Svelte, "
    grep -qi '"angular' package.json 2>/dev/null && fw="${fw}Angular, "
    grep -qi '"remix"' package.json 2>/dev/null && fw="${fw}Remix, "
    grep -qi '"hono"' package.json 2>/dev/null && fw="${fw}Hono, "
  fi
  if [[ -f "requirements.txt" || -f "pyproject.toml" ]]; then
    grep -qi "django" requirements.txt pyproject.toml 2>/dev/null && fw="${fw}Django, "
    grep -qi "flask" requirements.txt pyproject.toml 2>/dev/null && fw="${fw}Flask, "
    grep -qi "fastapi" requirements.txt pyproject.toml 2>/dev/null && fw="${fw}FastAPI, "
  fi
  [[ -f "go.mod" ]] && grep -qi "gin-gonic\|fiber\|echo" go.mod 2>/dev/null && fw="${fw}Go web framework, "
  [[ -f "Cargo.toml" ]] && grep -qi "actix\|axum\|rocket" Cargo.toml 2>/dev/null && fw="${fw}Rust web framework, "
  [[ -f "mix.exs" ]] && grep -qi "phoenix" mix.exs 2>/dev/null && fw="${fw}Phoenix, "
  [[ -f "composer.json" ]] && grep -qi "laravel" composer.json 2>/dev/null && fw="${fw}Laravel, "
  echo "${fw%, }" | sed 's/^$/Not detected/'
}

detect_test_framework() {
  local tf=""
  [[ -d "spec" ]] && tf="${tf}RSpec, "
  [[ -d "test" && -f "Gemfile" ]] && grep -qi "minitest" Gemfile 2>/dev/null && tf="${tf}Minitest, "
  if [[ -f "package.json" ]]; then
    grep -qi '"jest"' package.json 2>/dev/null && tf="${tf}Jest, "
    grep -qi '"vitest"' package.json 2>/dev/null && tf="${tf}Vitest, "
    grep -qi '"mocha"' package.json 2>/dev/null && tf="${tf}Mocha, "
    grep -qi '"playwright"' package.json 2>/dev/null && tf="${tf}Playwright, "
    grep -qi '"cypress"' package.json 2>/dev/null && tf="${tf}Cypress, "
  fi
  [[ -f "pyproject.toml" ]] && grep -qi "pytest" pyproject.toml 2>/dev/null && tf="${tf}pytest, "
  find . -maxdepth 3 -name "*_test.go" 2>/dev/null | head -1 | grep -q . && tf="${tf}Go testing, "
  grep -rq "#\[cfg(test)\]" . --include="*.rs" 2>/dev/null && tf="${tf}Rust tests, "
  [[ -d "test" && -f "mix.exs" ]] && tf="${tf}ExUnit, "
  echo "${tf%, }" | sed 's/^$/Not detected/'
}

detect_build_and_package() {
  local bp=""
  [[ -f "Makefile" ]] && bp="${bp}Make, "
  [[ -f "Dockerfile" || -f "docker-compose.yml" || -f "docker-compose.yaml" ]] && bp="${bp}Docker, "
  [[ -f "package-lock.json" ]] && bp="${bp}npm, "
  [[ -f "yarn.lock" ]] && bp="${bp}Yarn, "
  [[ -f "pnpm-lock.yaml" ]] && bp="${bp}pnpm, "
  [[ -f "bun.lockb" ]] && bp="${bp}Bun, "
  [[ -f "Gemfile.lock" ]] && bp="${bp}Bundler, "
  [[ -f "poetry.lock" ]] && bp="${bp}Poetry, "
  [[ -f "Cargo.lock" ]] && bp="${bp}Cargo, "
  [[ -f "go.sum" ]] && bp="${bp}Go modules, "
  echo "${bp%, }" | sed 's/^$/Not detected/'
}

detect_ci() {
  local ci=""
  [[ -d ".github/workflows" ]] && ci="${ci}GitHub Actions, "
  [[ -f ".gitlab-ci.yml" ]] && ci="${ci}GitLab CI, "
  [[ -f ".circleci/config.yml" ]] && ci="${ci}CircleCI, "
  [[ -f "Jenkinsfile" ]] && ci="${ci}Jenkins, "
  echo "${ci%, }" | sed 's/^$/Not detected/'
}

detect_db() {
  local db=""
  if [[ -f "config/database.yml" ]]; then
    grep -qi "postgres" config/database.yml 2>/dev/null && db="${db}PostgreSQL, "
    grep -qi "mysql" config/database.yml 2>/dev/null && db="${db}MySQL, "
    grep -qi "sqlite" config/database.yml 2>/dev/null && db="${db}SQLite, "
  fi
  if [[ -f "package.json" ]]; then
    grep -qi '"prisma"' package.json 2>/dev/null && db="${db}Prisma, "
    grep -qi '"mongoose"' package.json 2>/dev/null && db="${db}MongoDB, "
    grep -qi '"typeorm"' package.json 2>/dev/null && db="${db}TypeORM, "
    grep -qi '"drizzle"' package.json 2>/dev/null && db="${db}Drizzle, "
  fi
  grep -rq "redis" . --include="Gemfile" --include="package.json" --include="requirements.txt" 2>/dev/null && db="${db}Redis, "
  echo "${db%, }" | sed 's/^$/Not detected/'
}

detect_architecture() {
  local pat=""
  [[ -d "app/models" && -d "app/controllers" ]] && pat="${pat}MVC, "
  [[ -d "app/services" || -d "src/services" ]] && pat="${pat}Service Layer, "
  [[ -d "app/jobs" || -d "app/workers" ]] && pat="${pat}Background Jobs, "
  [[ -d "app/policies" ]] && pat="${pat}Policy Objects, "
  [[ -d "src/repositories" || -d "src/repo" ]] && pat="${pat}Repository Pattern, "
  [[ -d "src/middleware" ]] && pat="${pat}Middleware, "
  [[ -d "src/dto" || -d "src/schemas" ]] && pat="${pat}DTOs/Schemas, "
  [[ -d "src/domain" || -d "src/entities" ]] && pat="${pat}Domain Entities, "
  [[ -d "src/events" || -d "app/events" ]] && pat="${pat}Event-Driven, "
  echo "${pat%, }" | sed 's/^$/Not detected/'
}

get_dir_tree() {
  find . -maxdepth 3 -type d \
    -not -path '*/\.*' -not -path '*/node_modules*' -not -path '*/vendor*' \
    -not -path '*/__pycache__*' -not -path '*/target*' -not -path '*/dist*' \
    -not -path '*/build*' -not -path '*/.next*' -not -path '*/tmp*' \
    -not -path '*/log*' -not -path '*/coverage*' \
    2>/dev/null | sort | head -50 | sed 's|^\./||'
}

get_naming_samples() {
  find . -maxdepth 4 -type f \( -name "*.rb" -o -name "*.py" -o -name "*.ts" -o -name "*.js" \
    -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.kt" -o -name "*.ex" -o -name "*.php" \) \
    -not -path '*/test*' -not -path '*/spec*' -not -path '*/node_modules*' -not -path '*/vendor*' \
    2>/dev/null | head -15 | sed 's|^\./||' | sort
}

get_project_docs() {
  local docs=""
  [[ -f "README.md" || -f "README.rst" ]] && docs="${docs}README, "
  [[ -f "ARCHITECTURE.md" || -d "docs/adr" ]] && docs="${docs}Architecture docs, "
  [[ -f ".cursorrules" || -d ".cursor/rules" ]] && docs="${docs}Cursor rules, "
  [[ -f "CLAUDE.md" ]] && docs="${docs}Claude config, "
  [[ -f "AGENTS.md" ]] && docs="${docs}AGENTS.md, "
  [[ -f ".github/copilot-instructions.md" ]] && docs="${docs}Copilot instructions, "
  [[ -f "spectra-conventions.md" ]] && docs="${docs}SPECTRA conventions, "
  echo "${docs%, }" | sed 's/^$/None/'
}

get_convention_summary() {
  local summary=""
  local convention_files=(.cursorrules CLAUDE.md AGENTS.md .github/copilot-instructions.md ARCHITECTURE.md)
  for cf in "${convention_files[@]}"; do
    if [[ -f "$cf" ]]; then
      local lines
      lines=$(wc -l < "$cf" 2>/dev/null | tr -d ' ')
      summary="${summary}- **${cf}** (${lines} lines)\n"
    fi
  done
  if [[ -d ".cursor/rules" ]]; then
    local count
    count=$(find .cursor/rules -name "*.mdc" 2>/dev/null | wc -l | tr -d ' ')
    [[ "$count" -gt 0 ]] && summary="${summary}- **.cursor/rules/** (${count} .mdc files)\n"
  fi
  if [[ -d "docs/adr" ]]; then
    local count
    count=$(find docs/adr -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    [[ "$count" -gt 0 ]] && summary="${summary}- **docs/adr/** (${count} ADRs)\n"
  fi
  echo -e "${summary:-None detected}"
}

get_file_count() {
  find . -type f -not -path '*/\.*' -not -path '*/node_modules*' \
    -not -path '*/vendor*' -not -path '*/target*' 2>/dev/null | wc -l | tr -d ' '
}

# ─── Run Detection ────────────────────────────────────────────────────────────
echo -e "${BLUE}▸${NC} Detecting languages..."
LANGUAGES=$(detect_languages)
echo -e "${BLUE}▸${NC} Detecting frameworks..."
FRAMEWORKS=$(detect_framework)
echo -e "${BLUE}▸${NC} Detecting test frameworks..."
TEST_FW=$(detect_test_framework)
echo -e "${BLUE}▸${NC} Detecting build tools..."
BUILD_TOOLS=$(detect_build_and_package)
echo -e "${BLUE}▸${NC} Detecting CI..."
CI_SYSTEM=$(detect_ci)
echo -e "${BLUE}▸${NC} Detecting databases..."
DATABASE=$(detect_db)
echo -e "${BLUE}▸${NC} Detecting architecture..."
ARCH_PATTERNS=$(detect_architecture)
echo -e "${BLUE}▸${NC} Scanning structure..."
DIR_TREE=$(get_dir_tree)
NAMING_SAMPLES=$(get_naming_samples)
PROJECT_DOCS=$(get_project_docs)
CONVENTION_SUMMARY=$(get_convention_summary)
FILE_COUNT=$(get_file_count)
echo ""
echo -e "${GREEN}✓${NC} Detection complete"
echo ""

# ─── Generate Project Profile ─────────────────────────────────────────────────
echo -e "${YELLOW}▸${NC} Writing ${BOLD}${PROFILE_OUT}${NC}..."

cat > "$PROFILE_OUT" << EOF
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

Paste **${PROMPT_OUT}** into your preferred LLM to generate SPECTRA conventions for this project.

*SPECTRA v${SPECTRA_VERSION} — ${SPECTRA_REPO}*
EOF

# ─── Generate LLM Adaptation Prompt ──────────────────────────────────────────
echo -e "${YELLOW}▸${NC} Writing ${BOLD}${PROMPT_OUT}${NC}..."

cat > "$PROMPT_OUT" << EOF
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

*Prompt generated by SPECTRA v${SPECTRA_VERSION}*
EOF

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║   ✓ Analysis Complete                                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  ${BOLD}Files generated:${NC}"
echo -e "    📋 ${CYAN}${PROFILE_OUT}${NC}     — Project characteristics"
echo -e "    🤖 ${CYAN}${PROMPT_OUT}${NC}  — LLM prompt (paste into any LLM)"
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo -e "    1. Review ${PROFILE_OUT} for accuracy"
echo -e "    2. Copy ${PROMPT_OUT} into your preferred LLM"
echo -e "    3. Save the output as ${CYAN}spectra-conventions.md${NC}"
echo -e "    4. Start using SPECTRA for your next feature spec!"
echo ""
echo -e "  ${BOLD}Learn more:${NC} ${SPECTRA_REPO}"
echo ""
