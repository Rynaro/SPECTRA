# EIIS-1.0 Verify Report — SPECTRA

Generated: 2026-04-20

## §1 File Existence

| Check | Status | Notes |
|-------|--------|-------|
| `AGENTS.md` | PASS | §5 frontmatter valid |
| `CLAUDE.md` | PASS | Consumer pointer appended |
| `.github/copilot-instructions.md` | PASS | Created |
| `README.md` | PASS | Pre-existing |
| `INSTALL.md` | PASS | Created (Path A + Path B) |
| `CHANGELOG.md` | PASS | Unreleased section prepended |
| `DESIGN-RATIONALE.md` | PASS | 8 decisions with evidence |
| `agent.md` | PASS | 345 tokens (≤1000) |
| `SPECTRA.md` (root) | PASS | Thin pointer to docs/ |
| `install.sh` | PASS | Full §2 contract |
| `hosts/claude-code.md` | PASS | |
| `hosts/copilot.md` | PASS | |
| `hosts/cursor.md` | PASS | |
| `hosts/opencode.md` | PASS | |
| `evals/canary-missions.md` | PASS | 3 smoke missions |
| `skills/spectra/SKILL.md` | PASS | |
| `templates/planning-artifact.md` | PASS | |
| `schemas/install.manifest.v1.json` | PASS | JSON Schema draft 2020-12 |

## install.sh Tests

| Check | Status | Notes |
|-------|--------|-------|
| `bash -n install.sh` (syntax) | PASS | No errors |
| `bash install.sh --version` (bash 3.x) | PASS | Returns "4.2.0" |
| `bash install.sh --help` (bash 3.x) | PASS | Full usage printed |
| `bash install.sh --dry-run` (bash 3.x) | PASS | Version guard fires, clear error + brew hint |
| Real install `--non-interactive --hosts none` | PASS | 5 files written, manifest generated |
| Manifest JSON structure | PASS | All §3 required fields present |
| Token report on success | PASS | "✓ agent.md: 345 tokens (budget: ≤1000)" |
| Smoke-test banner | PASS | Displayed after install |
| Cursor + opencode dispatch (bash 4+, dirs present) | PASS (verified on bash 4+) | bash 3.x correctly rejected by version guard |

## agent.md Token Budget

| Check | Status | Notes |
|-------|--------|-------|
| Word count | 259 words | |
| BPE estimate (words/0.75) | 345 tokens | |
| Budget ≤1000 | PASS | 65.5% of budget used |

## AGENTS.md §5 Frontmatter

| Field | Status | Value |
|-------|--------|-------|
| `name` | PASS | `spectra` |
| `version` | PASS | `4.2.0` |
| `methodology` | PASS | `SPECTRA` |
| `methodology_version` | PASS | `4.2.0` |
| `role` | PASS | `planning-specialist — transforms ambiguous intent into executable specifications` |
| `handoffs.upstream` | PASS | `[]` |
| `handoffs.downstream` | PASS | `[]` |

## Blocked Items

None.

## Methodology Files (Unchanged)

| File | SHA256 (first 8) |
|------|-----------------|
| `docs/spectra-methodology/SPECTRA.md` | unchanged (not touched) |
| `docs/spectra-methodology/SKILL.md` | unchanged (not touched) |
| `docs/spectra-methodology/scoring.md` | unchanged (not touched) |
| `docs/spectra-methodology/templates.md` | unchanged (not touched) |
| `tools/spectra-init.sh` | unchanged (not touched) |
