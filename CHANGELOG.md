# Changelog

## [4.2.4] — methodology cleanup + self-contained install + commands/fit.sh

### Added
- `commands/fit.sh` — per-Eidolon subcommand entry point, invoked by the nexus CLI's generic `eidolons <eidolon> <sub>` dispatcher. Wraps `tools/spectra-init.sh` with a stable interface.
- Installer now copies `tools/` into `.eidolons/spectra/tools/` so the retrofit toolchain is self-contained at the installed target (no dependency on the source repo being present on disk).
- Installer now copies `docs/research/*.md` into `.eidolons/spectra/research/` so SPECTRA.md's scholarly citations resolve locally — no WebFetch, no permission prompts during agent activation.

### Changed
- `install.sh` rewrites `](../research/` → `](./research/` in the copied `SPECTRA.md` so relative citation links resolve against the new local `./research/` directory.
- `agent.md` Skill Loading table references now point at installed-target-relative paths (`SPECTRA.md`, `skills/planning/SKILL.md`, `research/THEORY.md`) instead of stale source-repo paths.

### Removed
- `agent.md` "Consumer Project Usage" block (user-onboarding prose the LLM was reading every activation — moved to README/INSTALL concern).
- `docs/spectra-methodology/SPECTRA.md` "Installing SPECTRA in Your Project" section (same reason — stack adaptation guidance belongs in user-facing docs, not in agent-loaded methodology). A short "Project Conventions (optional)" replaces it with just the LLM-relevant semantics.

## [Unreleased] — EIIS-1.0 conformance

### Added
- `AGENTS.md` — root marker with EIIS §5 frontmatter; enables Copilot/Cursor/OpenCode auto-discovery
- `agent.md` — always-loaded entry point (345 tokens, well within ≤1000 budget)
- `SPECTRA.md` (root) — EIIS §1 `<EIDOLON>.md` root pointer to `docs/spectra-methodology/SPECTRA.md`
- `install.sh` — EIIS §2 compliant installer (8 flags: `--target`, `--hosts`, `--force`, `--dry-run`, `--non-interactive`, `--manifest-only`, `--version`, `-h`)
- `INSTALL.md` — human cross-host install guide covering both EIIS and direct adoption paths
- `DESIGN-RATIONALE.md` — research-to-decision mapping (8 architectural decisions)
- `.github/copilot-instructions.md` — Copilot primary entry pointing at `AGENTS.md`
- `hosts/claude-code.md`, `hosts/copilot.md`, `hosts/cursor.md`, `hosts/opencode.md` — per-host wiring guides
- `evals/canary-missions.md` — 3 smoke missions (greenfield, brownfield, ambiguous-request)
- `skills/spectra/SKILL.md` — EIIS-path on-demand skill file (adapted from `docs/spectra-methodology/SKILL.md`)
- `templates/planning-artifact.md` — EIIS-path template pointer
- `schemas/install.manifest.v1.json` — JSON Schema draft 2020-12 for `install.manifest.json`

### Changed
- `CLAUDE.md` — appended "Consumer Project Usage" section with `@agents/spectra/agent.md` pointer

### Notes
- All existing methodology content in `docs/spectra-methodology/` and `tools/spectra-init.sh` is unchanged
- EIIS `install.sh` and `tools/spectra-init.sh` serve different purposes; see `INSTALL.md`
- Audit trail: `.eidolons-audit/`

## [4.2.0] - 2026-03-01 — GitHub Release

### Added
- **THEORY.md** — PhD-level theoretical foundations:
  - Expected Value of Perfect Information (EVPI) for confidence gating
  - Plan Entropy metric for adaptive verification budgets
  - Cognitive Load Theory formalization (Miller's Law justification for 3–5 hypotheses)
  - Scoring Calibration Protocol (anchor-based inter-rater reliability)
  - Failure Taxonomy (8 plan failure modes with diagnostic signals)
  - Diminishing Returns Detection for refinement cycles (Δ < 0.3 stop criterion)
  - Bayesian Updating in Pattern Phase
  - Connections to lightweight formal verification methods
- Failure taxonomy integrated into scoring.md Test phase
- Scoring calibration protocol in scoring.md
- Adaptive verification budget notes in SPECTRA.md Test phase
- Oscillation detection in SPECTRA.md Refine phase

### Changed
- `spectra-init.sh` fully rewritten: cleaner detection, better LLM prompt, cross-platform (Linux/macOS/WSL)
- README reorganized for GitHub: prominent benchmarks banner, usage-purpose file organization, proper repo URLs
- All `rynaro/spectra-planning` placeholders replaced with `Rynaro/SPECTRA`
- Repository URLs point to `github.com/Rynaro/SPECTRA`
- Version bumped to 4.2.0

## [4.1.0] - 2026-03-01

### Added
- `tools/spectra-init.sh` — Shell script to analyze any project and generate LLM adaptation prompts
- Generic API feature example (Node.js/TypeScript) alongside Rails example
- Anti-patterns file with correct alternatives
- Benchmarks section with designed evaluation framework and "incoming" status
- PhD-level enhancements: stakeholder mapping (Scope), failure pattern catalog (Pattern), rejected alternative documentation (Explore), risk tags P0/P1/P2 (Construct), refinement oscillation tracking (Refine), cognitive load assessment (CLARIFY)
- 6-Layer Verification checklist in scoring.md
- Full 7-dimension hypothesis rubric (1-10 scale with weights) in scoring.md
- State Machine JSON template in templates.md

### Changed
- Repository restructured by usage purpose: `docs/`, `tools/`, `examples/`
- All agent names (company-specific) replaced with generic capability classes
- Rails-specific patterns acknowledged as origin but made stack-agnostic
- Examples separated from methodology into own directory
- SKILL.md reduced to pure routing card (~100 words)
- Templates updated with rejection documentation, risk tags, state machine format
- Version bump to distinguish open-source release

### Removed
- Company-specific agent names (Archie, Dilton, Jughead, Betty, Moose, Hiram, Reggie)
- EOS Rock references (replaced with generic "Strategic Goal / Quarterly Objective")
- Rails-specific pattern names from core methodology (FlowObject, Repository, ViewComponent)

## [4.0.0] - 2026-02-18

### Added
- CLARIFY phase (pre-SPECTRA disambiguation)
- 6-layer verification (structural → adversarial)
- Reflexion-style refinement protocol
- Plan artifact persistence (MD + YAML + JSON)
- Adaptive replanning with 3-step lookahead
- Context compaction and anti-drift mechanisms
- Preflight checklist replacing verbose Boundaries section
- Research foundation: 15+ papers, commercial analysis, synthesis

### Changed
- 54% token reduction through architectural separation (SKILL.md as routing card, SPECTRA.md as single source)
- Confidence bands refined: 50-69% = COLLABORATE, 70-84% = VALIDATE
- Self-critique protocol upgraded from generic "improve" to Reflexion-style

## [3.1.0] - 2025-01 (Internal)

- Initial SPECTRA methodology with 7-phase cycle
- Company-specific agent routing
- Rails-focused examples and patterns
