# SPECTRA — Installation Guide

SPECTRA supports two installation paths:

| Path | Use when | Command |
|------|---------|---------|
| **EIIS Eidolons framework** | Composing multiple Eidolons via `eidolons-init` | `bash install.sh` |
| **Direct SPECTRA adoption** | Installing SPECTRA into your own project | `bash tools/spectra-init.sh` |

Both paths are maintained. They are complementary, not competing.

---

## Path A — EIIS Eidolons Framework (`install.sh`)

Installs SPECTRA files to a target directory and creates per-host dispatch files.
Designed for use with `eidolons-init` and other EIIS-compliant tools.

### Prerequisites

- bash 3.2+ (macOS default is fine)
- Standard coreutils (`cp`, `mkdir`, `wc`, `date`)

### Quick Install

```bash
# Auto-detect consumer hosts, install to ./.eidolons/spectra/
bash install.sh

# Explicit target and hosts
bash install.sh --target ./.eidolons/spectra --hosts claude-code,copilot

# Dry run — see what would be created without writing files
bash install.sh --dry-run

# CI/automation
bash install.sh --non-interactive --hosts all
```

### Options

```
--target DIR          Install directory (default: ./.eidolons/spectra)
--hosts LIST          claude-code,copilot,cursor,opencode,all (default: auto)
--force               Overwrite existing install
--dry-run             Print actions without writing files
--non-interactive     No prompts; exit 3 on existing install, exit 4 on token overrun
--manifest-only       Only emit install.manifest.json
--version             Print SPECTRA version
-h, --help            Show help
```

### What gets installed

```
.eidolons/spectra/
├── agent.md                     ← always-loaded entry point (≤1000 tokens)
├── SPECTRA.md                   ← full methodology
├── SKILL.md                     ← quick routing card
├── scoring.md                   ← rubrics and matrices
├── templates.md                 ← output formats
└── install.manifest.json        ← EIIS manifest (validated by schemas/install.manifest.v1.json)

# Per-host dispatch files created in consumer project:
CLAUDE.md                        ← appended: @.eidolons/spectra/agent.md pointer
.github/copilot-instructions.md  ← created or appended
.cursor/rules/spectra.mdc        ← created (only if .cursor/ exists)
.opencode/agents/spectra.md      ← created (only if .opencode/ exists)
```

### Host-specific guides

- [Claude Code](hosts/claude-code.md)
- [GitHub Copilot](hosts/copilot.md)
- [Cursor](hosts/cursor.md)
- [OpenCode](hosts/opencode.md)

---

## Path B — Direct SPECTRA Adoption (`tools/spectra-init.sh`)

Full project-analysis + adaptation-prompt-generation workflow. Detects your tech stack,
identifies existing conventions, and generates an LLM prompt to create
SPECTRA conventions tailored to your codebase.

### Prerequisites

- bash 3.2+ (macOS default is fine)
- Standard coreutils

### Quick Install

```bash
# Interactive (recommended for first install)
bash tools/spectra-init.sh /path/to/your/project

# Non-interactive (CI/automation)
SPECTRA_VENDOR=claude SPECTRA_MODE=skill SPECTRA_YES=1 \
  bash tools/spectra-init.sh /path/to/your/project
```

### What gets installed

```
<your-project>/
├── .spectra/
│   ├── plans/                        ← your planning artifacts
│   └── setup/
│       ├── project-profile.md        ← detected tech stack
│       ├── adaptation-prompt.md      ← paste into any LLM
│       └── spectra-conventions.md    ← fill after running adaptation prompt

# Vendor-specific files (depending on selected vendor + mode):
.claude/agents/spectra-planner.md           ← Claude Code agent mode
.claude/skills/spectra-methodology/         ← Claude Code skill mode
.github/agents/spectra-planner.agent.md     ← Copilot agent mode
.cursor/rules/spectra-methodology.mdc       ← Cursor skill mode
```

### Non-interactive environment variables

| Variable | Values | Default |
|----------|--------|---------|
| `SPECTRA_VENDOR` | `claude`, `copilot`, `cursor` | Auto-detect |
| `SPECTRA_MODE` | `agent`, `skill` | Prompt user |
| `SPECTRA_YES` | `1` | Prompt user |

---

## Verification

After either installation path, verify SPECTRA is working:

```
Using SPECTRA, plan: "Add a health check endpoint to a REST API."
```

Expected: CLARIFY (brief), Scope artifact, Explore with hypotheses, final
dual-format specification. No code written.

See [`evals/canary-missions.md`](evals/canary-missions.md) for three structured
smoke missions covering greenfield, brownfield, and ambiguous-request scenarios.

---

## Greenfield vs. Brownfield

| Scenario | Recommended path |
|----------|-----------------|
| New project, adopting SPECTRA directly | Path B — project analysis included |
| Existing Eidolons multi-agent setup | Path A — EIIS-compliant uniform interface |
| CI/automation in Eidolons framework | Path A with `--non-interactive` |
| Brownfield with existing conventions | Path B — see [`docs/research/RETROFIT.md`](docs/research/RETROFIT.md) |

---

*SPECTRA v4.2.0 — CC BY-SA 4.0*
