# EIIS-1.0 Scout Report — SPECTRA

Generated: 2026-04-20

## Eidolon Identity

- **Name (slug)**: `spectra`
- **Version**: `4.2.0`
- **Methodology**: `SPECTRA — Strategic Specification through Deliberate Reasoning`
- **Cycle**: `CLARIFY → S → P → E → C → T → R → A → PERSIST/ADAPT`
- **Role class**: planning-specialist
- **Prior EIIS audit**: none (fresh run — no `.eidolons-audit/` existed, no `install.manifest.json`)
- **Delta mode**: NO

## Root File Inventory

```
SPECTRA/
├── .git/
├── .github/
│   ├── CONTRIBUTING.md
│   └── ISSUE_TEMPLATE/
│       ├── case_study_submission.md
│       └── methodology_feedback.md
├── .gitignore
├── CHANGELOG.md
├── CLAUDE.md
├── docs/
│   ├── benchmarks/
│   ├── research/
│   │   ├── REFERENCES.md
│   │   ├── RETROFIT.md
│   │   ├── SYNTHESIS.md
│   │   └── THEORY.md
│   └── spectra-methodology/
│       ├── SKILL.md           (992 bytes — routing card)
│       ├── SPECTRA.md         (14,377 bytes — full cognitive architecture)
│       ├── scoring.md         (9,911 bytes)
│       └── templates.md       (6,898 bytes)
├── examples/
│   ├── anti-patterns.md
│   ├── generic-api-feature.md
│   └── rails-player-import.md
├── LICENSE                    (CC BY-SA 4.0)
├── README.md
└── tools/
    ├── assets/
    │   ├── methodology/       (bundled copies of docs/spectra-methodology/*)
    │   └── templates/
    │       ├── agent-planner.md.tmpl
    │       └── conventions-stub.md
    ├── lib/
    │   ├── config.sh          (SPECTRA_VERSION="4.2.0")
    │   ├── core.sh            (readonly SPECTRA_VERSION="4.2.0")
    │   ├── detector_registry.sh
    │   ├── detectors/         (architecture, build, ci, conventions, database, frameworks, languages, testing)
    │   ├── errors.sh
    │   ├── flows/             (main_flow, mode_flow, summary_flow, vendor_flow)
    │   ├── installer.sh
    │   ├── tui.sh
    │   ├── vendor_registry.sh
    │   └── vendors/           (claude.sh, copilot.sh, cursor.sh)
    ├── README.md
    └── spectra-init.sh        (entry point for tools/ installer)
```

## EIIS §1 Required File Check

| Path | Status | Notes |
|------|--------|-------|
| `AGENTS.md` | **MISSING** | |
| `CLAUDE.md` | EXISTS | Describes methodology repo; lacks `@agents/spectra/agent.md` pointer and consumer-project usage section |
| `.github/copilot-instructions.md` | **MISSING** | `.github/` dir exists |
| `README.md` | EXISTS | Comprehensive, v4.2.0 |
| `INSTALL.md` | **MISSING** | |
| `CHANGELOG.md` | EXISTS | Keep-a-Changelog format, latest entry 4.2.0 |
| `DESIGN-RATIONALE.md` | **MISSING** | |
| `agent.md` | **MISSING** | |
| `SPECTRA.md` (root) | **MISSING** | Full spec lives at `docs/spectra-methodology/SPECTRA.md` |
| `install.sh` | **MISSING** | `tools/spectra-init.sh` exists but different interface (see below) |
| `hosts/claude-code.md` | **MISSING** | `hosts/` dir absent |
| `hosts/copilot.md` | **MISSING** | |
| `hosts/cursor.md` | **MISSING** | |
| `hosts/opencode.md` | **MISSING** | |
| `evals/canary-missions.md` | **MISSING** | `evals/` dir absent |
| `skills/<phase>/SKILL.md` | **MISSING** | `skills/` dir absent; routing card at `docs/spectra-methodology/SKILL.md` |
| `templates/<artifact>.md` | **MISSING** | `templates/` dir absent; templates at `docs/spectra-methodology/templates.md` |
| `schemas/install.manifest.v1.json` | **MISSING** | `schemas/` dir absent |

## Existing Installer Analysis (`tools/spectra-init.sh`)

[FINDING-001] Interface: positional arg `[TARGET_DIR]` only — no `--target`, `--hosts`, `--force`, `--dry-run`, `--non-interactive`, `--manifest-only`, `--version`, `-h`/`--help` — evidence: `tools/spectra-init.sh:6-16`, `tools/lib/config.sh:26-29`

[FINDING-002] Non-interactive mode via env vars (`SPECTRA_VENDOR`, `SPECTRA_MODE`, `SPECTRA_YES`), not `--non-interactive` flag — evidence: `tools/lib/config.sh`

[FINDING-003] No `install.manifest.json` emission — evidence: `tools/lib/installer.sh` (no manifest write function)

[FINDING-004] No consumer-host auto-detection by dir presence; uses `SPECTRA_VENDOR` env var — evidence: `tools/lib/vendor_registry.sh`

[FINDING-005] Supported vendors: `claude`, `copilot`, `cursor` — no `opencode` — evidence: `tools/lib/vendors/` listing

[FINDING-006] Purpose is project-analysis + adaptation-prompt-generation + file placement; substantially broader than EIIS §2 scope. A new root `install.sh` should implement EIIS §2 separately; `tools/spectra-init.sh` remains untouched.

## CLAUDE.md Analysis

[FINDING-007] Exists. Describes methodology repo structure, contribution rules, writing conventions. Does NOT contain `@agents/spectra/agent.md` pointer or consumer-project usage section required by EIIS §4.

## `.github/copilot-instructions.md`

[FINDING-008] Missing. `.github/` directory exists — no risk of directory creation conflict.

## `AGENTS.md` Frontmatter (§5)

[FINDING-009] File missing entirely.

## Methodology File Location

[FINDING-010] All core methodology content lives under `docs/spectra-methodology/` — not at repo root. Root `SPECTRA.md` must be created as a pointer/stub. Methodology files are NOT to be moved per CLAUDE.md contribution rules.

## `agent.md` Token Count

[FINDING-011] File does not exist. Target: draft ≤750 words (→ ≤1000 BPE-approx tokens via word_count/0.75).

## EIIS_VERSION File

Not present. No version conflict to resolve.
