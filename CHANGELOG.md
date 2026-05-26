# Changelog

## [Unreleased]

## [4.4.1] — 2026-05-26

### Fixed
- `install.sh` now sweeps legacy v1.2-era artefacts on upgrade: removes stale
  `<TARGET>/SPECTRA.md` and any `<TARGET>/skills/planning/` subdir tree left
  behind by pre-v1.3 installs. Fresh installs are unaffected (no-op when files
  are absent). `cleanup_legacy_v1_2` helper runs before the first content write.

## [4.4.0] — 2026-05-25 — EIIS v1.3 install normalization

### Changed
- BREAKING: full-spec destination renamed `SPECTRA.md` → `SPEC.md` (EIIS v1.3 §1.8). Source file renamed `docs/spectra-methodology/SPECTRA.md` → `docs/spectra-methodology/SPEC.md`.
- BREAKING: skills layout flattened from `skills/<skill>/SKILL.md` (subdir) to `skills/<skill>.md` (flat, source-of-truth). Vendor copies at `.claude/skills/spectra-<skill>/SKILL.md` unchanged.
- `install.sh`: `wire_skill` helper rewritten to EIIS v1.3 §4.2.4 dual-write contract (source-of-truth flat path + Claude Code vendor copy). Bash 3.2 compatible.
- `EIDOLON_VERSION` bumped `4.3.2` → `4.4.0` (MINOR — breaking install-layout change).

### Removed
- Out-of-sync duplicate `SPECTRA.md` at repo root deleted. Authoritative source is `docs/spectra-methodology/SPEC.md`.

### Compliance
- `EIIS_VERSION` bumped `1.2` → `1.3`.

## [4.3.2] — 2026-05-13 — declare ECL v2.0 conformance

### Changed
- `ECL_VERSION` file: `1.2` → `2.0`. Targets ECL v2.0
  (`Rynaro/eidolons-ecl@v2.0.0`; spec `spec/ecl-2.0.md` introducing ISE
  trust hierarchy). SPECTRA's emit envelopes remain byte-compatible
  (backward-compatible per ECL §7.3 — 12-month compatibility window
  through 2027-05-13).
- `agent.md` + `AGENTS.md` frontmatter: `comm.envelope_version`
  `"1.2"` → `"2.0"`.
- `install.sh`: `EIDOLON_VERSION` `4.3.1` → `4.3.2` (PATCH bump —
  declaration-only change; no behaviour change, no schema change, no
  envelope-shape change).

### Notes
- Declaration-only patch bump; no behaviour change, no schema change,
  no envelope-shape change.
- SPECTRA emit envelopes remain byte-compatible with ECL v2.0
  (backward-compatible per ECL §7.3 — 12-month compatibility window
  through 2027-05-13).
- Companion patches: ATLAS already merged as v1.5.2; APIVR-Δ, IDG,
  FORGE, VIGIL follow. All six Eidolons need the bump per ECL v2.0.0
  publication.
- Refs: `Rynaro/eidolons-ecl@v2.0.0`.

## [4.3.1] — 2026-05-12 — Declare ECL v1.2 conformance

### Changed
- `ECL_VERSION` file: `1.0` → `1.2`. Targets the latest ECL spec
  (`Rynaro/eidolons-ecl@v1.2.0`); SPECTRA's emit envelopes remain
  byte-compatible (v1.2 is backward-compatible with v1.0 per ECL §1.1.1).
- `agent.md` + `AGENTS.md` frontmatter: `comm.envelope_version`
  `"1.0"` → `"1.2"`.
- `install.sh`: `EIDOLON_VERSION` `4.3.0` → `4.3.1` (PATCH bump —
  declaration-only change; no behaviour change).

### Notes
- No envelope-format changes. v1.0 envelopes already emitted by older
  SPECTRA releases are valid under v1.2 conformance.
- HMAC-SHA-256 RECOMMENDED at `trust_level=high` per ECL v1.1 (gate
  I-5). SPECTRA's emit edge (spectra → apivr) uses `trust_level=standard`
  per `contracts/spectra-to-apivr.yaml`; no change required.

### Added (carried over from previous [Unreleased] entry)
- `.github/workflows/release.yml` — adopts the eidolons-nexus release-integrity contract by calling the reusable `eidolon-release-template.yml` from `Rynaro/eidolons`. Triggered via `workflow_dispatch` with a SemVer input; the template validates EIIS conformance, builds release metadata (commit, tree, `archive_sha256`, optional `manifest_sha256`), creates the `vX.Y.Z` tag, attests release artifacts (GitHub artifact attestation), and publishes a GitHub Release. The nexus maintainer then runs `Roster Intake` to publish per-version release integrity metadata into the roster.

## [4.3.0] — 2026-05-08

### Added
- `ECL_VERSION` — single-line file (`1.0`) declaring the ECL spec version this Eidolon emits. Read by `install.sh` at install time and propagated into `install.manifest.json` as `ecl_version_emitted`. Presence gates all envelope emission (opt-in posture: no `ECL_VERSION` → no envelope, no behaviour change for non-ECL consumers).
- `schemas/ecl-envelope.v1.json` — vendored ECL v1.0 envelope schema with the `performative.v1.json#/$defs/performative` cross-file `$ref` inlined as the explicit ten-value enum at both call sites. Self-contained; `jq empty schemas/*.json` passes without fetching neighbour files.
- `schemas/spec-profile.v1.json` — vendored ECL per-Eidolon profile schema for SPECTRA's `spec` artefact kind. The `_base-profile.v1.json` `allOf` is inlined (base `required` keys and `properties` merged into a single `type: object`); `eidolon` constrained to `spectra`, `kind` constrained to `spec`.
- `templates/spec.envelope.json` — concrete envelope skeleton with SPECTRA-specific fields hard-coded (`from.eidolon: spectra`, `to.eidolon: apivr`, `performative: PROPOSE`, `edge_origin: roster`, `artifact.kind: spec`, `integrity.method: sha256`). UUIDs and sha256 left as `<placeholder>` for the emitting agent to fill at runtime.
- **Assemble-phase ECL emission step** — `docs/spectra-methodology/SPECTRA.md` Assemble deliverable #4 and `skills/planning/SKILL.md` ECL emission exit gate. When `ECL_VERSION` is present, the emitter MUST produce `<payload>.envelope.json` co-located with the Markdown spec, with `integrity.value` = sha256 of the Markdown payload bytes at emit time.
- `comm.envelope_version: "1.0"` YAML frontmatter key added to `agent.md` and `AGENTS.md`.
- **§ECL Compatibility** section in `docs/spectra-methodology/SPECTRA.md` (between Theoretical Foundations and Project Conventions) — declares ECL version, schema paths, hand-off contract, required spec sections, opt-in posture, and known follow-ups.
- **DR-09** in `DESIGN-RATIONALE.md` — ECL emission opt-in; opt-in posture rationale; sha256 integrity gate for AiTM/prompt-infection defence (ECL §6.2.2; ACL 2025 Findings — Agent-in-the-Middle Attacks); ATLAS v1.5.0 precedent.
- **§ECL Envelope Sidecar** subsection in `templates/planning-artifact.md` — file location, required fields table, sha256 anchor contract, when emitted, pointer to `templates/spec.envelope.json`.

### Changed
- `EIDOLON_VERSION` bumped `4.2.11` → `4.3.0` in `install.sh`. Minor bump (not patch) because ECL emission adds net-new artefacts alongside the existing dual-format output — additive, non-breaking, mirrors the ATLAS v1.4.2 → v1.5.0 minor bump precedent.
- `install.sh` manifest heredoc gains top-level `ecl_version_emitted` key (populated from `ECL_VERSION` content; defaults to empty string when `ECL_VERSION` absent).
- `install.sh` now creates `${TARGET}/schemas/` directory and copies `ECL_VERSION`, `schemas/spec-profile.v1.json`, `schemas/ecl-envelope.v1.json`, `templates/spec.envelope.json` when `ECL_VERSION` is present in the source tree. Copy calls use the existing `copy_file` helper; Bash 3.2 compatible.
- `EIIS_VERSION` bumped `1.1` → `1.2`. EIIS v1.2 GA'd 2026-05-08 alongside ECL v1.0; bumping in the same PR keeps the EIIS conformance gate aligned with the declared version.
- `.github/workflows/release.yml` `eiis-version` input bumped `"1.1"` → `"1.2"` to match `EIIS_VERSION`.
- `skills/planning/SKILL.md` version footer `*SPECTRA v4.2.8*` → `*SPECTRA v4.3.0*`.

### Compliance
- `jq empty schemas/*.json` — clean across all three schemas (`install.manifest.v1.json`, `ecl-envelope.v1.json`, `spec-profile.v1.json`). No cross-file `$ref`s remain in the vendored schemas.
- `shellcheck -x -S error install.sh` — clean. No new bash 4+ features introduced; `ECL_VERSION_EMITTED` read uses `head -1 | tr -d '[:space:]'`; copy block guarded by `[[ -f ... ]]`. Bash 3.2 floor preserved.
- Idempotent re-runs: two consecutive `bash install.sh --target /tmp/spectra-X --hosts claude-code --force` runs produce byte-identical manifests except `installed_at`; written files are sha256-stable.

### Known follow-ups
- The `apivr → spectra-via-vigil` systemic-replan round-trip (`spectra@PROPOSE → apivr@ACKNOWLEDGE → apivr@ESCALATE → vigil@INFORM → spectra@REQUEST(replan)`) has no published contract in `eidolons-ecl/contracts/` yet. Resolution: a later PR on `eidolons-ecl` adding the missing contract first, then on SPECTRA referencing it.

## [4.2.11] — 2026-05-04

### Fixed
- Add `examples/install.manifest.json` fixture so EIIS v1.1 conformance
  check returns exit 0 (was exit 4 / WARN on M0). This silences the
  `⚠ spectra fails EIIS conformance` line emitted by `eidolons sync`.
  No behavioural change to the installer.

## [4.2.10] - 2026-04-26 — Re-vendor EIIS v1.1 schema (codex enum)

### Fixed
- `schemas/install.manifest.v1.json` re-vendored from EIIS v1.1 — the previously bundled copy lacked `codex` in the `hosts_wired` enum, causing the EIIS conformance checker's M14 (JSON Schema validation) to fail when a validator (`ajv` / `python -m jsonschema`) was on PATH. Pure schema fix; no install.sh behaviour change.

## [4.2.9] — EIIS v1.1 conformance + OpenAI Codex host support

### Added
- `EIIS_VERSION` file at the repo root declaring `1.1`. Resolves drift D-6 (the v1.0 warn-only signal that Eidolons declare which EIIS minor they target) and lets the EIIS conformance checker run the v1.1 gates including §4.5 (Codex subagent contract) against this repo.
- `codex` host wiring in `install.sh`. The `--hosts` parser accepts `codex` directly, the `auto` detector adds `codex` when `.codex/` is present (or when root `AGENTS.md` exists without `.github/`, per the cross-vendor agents.md convention), and `--hosts all` now expands to `claude-code,copilot,cursor,opencode,codex`. The `auto` warn message and `--help` output advertise the new option.
- `.codex/agents/spectra.md` subagent dispatch is written when `codex` is wired. Frontmatter follows OpenAI's Codex subagent contract — required `name: spectra` + `description:` (decision-ready specifications, scoring rubrics, validation gates). Body mirrors the inline `.claude/agents/spectra.md` prompt: same "On activation" hook (read `.spectra/setup/spectra-conventions.md` if present, confirm outputs under `.spectra/`) and the same References block, so a Codex invocation resolves to the same pipeline a Claude Code subagent invocation does.
- Root `AGENTS.md` is now treated as a `codex`-and-`copilot`-shared surface per EIIS v1.1 §4.1.0. When `codex` is in the host list, `install.sh` upserts the marker-bounded `<!-- eidolon:spectra start --> … <!-- eidolon:spectra end -->` block into root `AGENTS.md` regardless of `--shared-dispatch` (Codex's primary instruction surface). The write is gated against double-emission when both `--shared-dispatch` and `codex` are in play, so the manifest still reports `AGENTS.md` exactly once.

### Changed
- Installer header comment and `--help` output relabelled "EIIS v1.0" → "EIIS v1.1". Bumped `EIDOLON_VERSION` to `4.2.9`.
- v1.0-conformant invocations remain conformant: the `codex` pathway is fully optional — `--hosts claude-code,copilot,cursor,opencode` is byte-identical to the v4.2.8 behaviour. EIIS v1.1 §4.5 marks the Codex surface OPTIONAL.

### Compliance
- EIIS v1.1 conformance check (`bash check.sh /path/to/SPECTRA`) passes all MUSTs at `EIIS_VERSION 1.1`. The pre-patch state passed all MUSTs but emitted a grandfathered D-6 warn (missing `EIIS_VERSION`); the post-patch state clears that warn. Bash 3.2 compatibility preserved; idempotent re-runs produce byte-identical output (only `installed_at` differs). `shellcheck -x -S error install.sh` is clean.

## [4.2.8] — conventions + path discipline wired into .claude/agents/ subagent

### Changed
- The `.claude/agents/spectra.md` subagent dispatch (written by `install.sh`) now carries the **conventions-loading hook and output-path discipline inline**. Previously the subagent dispatch was a thin summary that delegated to `.eidolons/spectra/agent.md` — but Claude Code reads the subagent file first and an agent might not eagerly follow the pointer, so SPECTRA sessions could proceed without ever loading `.spectra/setup/spectra-conventions.md`. The subagent now has an explicit "On activation" section telling the agent to (a) read the conventions file if present, (b) confirm all outputs live under `.spectra/`.
- Skill-load reference in the subagent corrected: was `${TARGET}/SKILL.md`, now `${TARGET}/skills/planning/SKILL.md` — matches the canonical installed layout.
- Version footer in `skills/planning/SKILL.md` updated to track current patch.

## [4.2.7] — fit-only lite mode (skip redundant vendor install)

### Added
- `--fit-only` flag on `tools/spectra-init.sh` (also accepts `SPECTRA_FIT_ONLY=1` env var). Runs the retrofit in **lite mode**: detect stack → generate `.spectra/setup/project-profile.md`, `adaptation-prompt.md`, `spectra-conventions.md` stub. **Skips vendor selection, mode selection, and vendor methodology install.** The full-install path is unchanged for users running `bash tools/spectra-init.sh` directly.
- Dedicated fit-plan preview (`_show_fit_only_plan` in `main_flow.sh`) that explains the lite mode and lists only the fit artefacts being created.

### Changed
- `commands/fit.sh` now invokes the retrofit tool with `--fit-only`. When users run `eidolons spectra fit`, they get the project-fit pass only — no re-install of SPECTRA methodology into `.claude/skills/spectra-methodology/` (which the eidolons flow already handled). Before this change, `eidolons spectra fit` was doing a full install every time, which was redundant and re-wrote vendor files that eidolons owned.
- Summary banner shows "Fit complete" + a note clarifying that the methodology is wired via eidolons, so the fit pass only emitted `.spectra/setup/` artefacts.

## [4.2.6] — path discipline + explicit conventions wiring

### Added
- **Output Discipline (P0 — non-negotiable)** section in `SPECTRA.md`. Canonical layout (`setup/`, `plans/`, `state/`, `logs/`) made explicit, with hard rule: every file the agent writes lives under `.spectra/`. No scattering to project root, `docs/`, or arbitrary paths.
- P0 rule #7 in `agent.md` enforcing the same output-path discipline. The agent-level contract now stops at "produce specifications" _and_ "stay under `.spectra/`".
- "On Activation" block in `agent.md` + `skills/planning/SKILL.md` instructing the agent to load `.spectra/setup/spectra-conventions.md` at the start of every session if present, fall back to generic defaults otherwise.
- Preflight checklist in `SPECTRA.md` gains two entries: (a) conventions loaded if present, (b) every output path starts with `.spectra/`.

### Changed
- CLARIFY step 4 (`SPECTRA.md:32`) now spells out the full conventions path (`.spectra/setup/spectra-conventions.md`), the override semantics ("supersedes generic placeholders"), and the fallback behaviour ("generic defaults"). Previously this was a casual parenthetical.
- Pattern step 2 (`SPECTRA.md:65`) references the conventions file by its canonical path when ranking codebase matches.
- CONSTRUCT output path (`SPECTRA.md:122`) changed from `plans/{date}-{feature}.md` → `.spectra/plans/{date}-{feature}.md`.
- PERSIST diagram (`SPECTRA.md:192-209`) rooted at `.spectra/` with every subdirectory made explicit (setup, plans, state, logs).
- `docs/spectra-methodology/templates.md` "Convention Map" section fixed — previously said "project root", now correctly says `.spectra/setup/spectra-conventions.md` with a note that it's never duplicated into vendor folders.
- `docs/research/RETROFIT.md` references to `spectra-conventions.md` now carry the full `.spectra/setup/` path (3 call sites).
- `examples/anti-patterns.md` plan-path example updated.
- Synced `tools/assets/methodology/{SPECTRA,SKILL,templates}.md` with the updated sources so the retrofit-tool's vendor installers emit the corrected content into `.claude/skills/`, `.github/instructions/`, `.cursor/rules/`.

## [4.2.5] — bash 3.2 compatibility for tools/

### Changed
- `tools/` refactored to run on bash 3.2 (macOS default) instead of requiring bash 4+. `eidolons spectra fit` and `bash tools/spectra-init.sh` now work out of the box on macOS without `brew install bash`.
- Associative arrays (`declare -gA`) in `detector_registry.sh`, `vendor_registry.sh`, and `detectors/conventions.sh` replaced with ordered-key indexed arrays plus one indirectly-named scalar per key. Public APIs (`register_detector`, `run_detectors`, `register_vendor`, `vendor_install`, `get_convention_summary`, …) unchanged — all internal refactor.
- `DETECTION_RESULTS` (previously an associative array) is now 8 scalar globals (`DETECTION_RESULT_LANGUAGE`, `DETECTION_RESULT_FRAMEWORK`, …). Consumer sites in `installer.sh` and `flows/main_flow.sh` updated.
- `declare -g` removed from `errors.sh` — plain globals at module top level are sufficient.
- `mapfile -t` replaced with `while IFS= read -r` loops in `flows/vendor_flow.sh` (3 call sites).
- `${var^^}` and `${var,,}` (bash 4 case-conversion operators) replaced with `tr` in `tui.sh` (2 call sites).
- All array iterations guarded with `"${arr[@]+"${arr[@]}"}"` where the array can legitimately be empty — required for bash 3.2 under `set -u`.
- `require_bash_version` floor lowered from 4 to 3.2. Signature now accepts `<major> <minor>` (still backwards-compatible — defaults to 3.2).

### Added
- Shared `_spectra_sanitize_key` helper in `core.sh` for building indirect variable names from arbitrary keys.

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
