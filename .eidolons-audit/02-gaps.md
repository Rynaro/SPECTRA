# EIIS-1.0 Gap Analysis — SPECTRA

Generated: 2026-04-20

## Gap Table

| Gap ID | File | Class | Severity | Reason | Proposed Action |
|--------|------|-------|----------|--------|-----------------|
| GAP-001 | `AGENTS.md` | CREATE | blocker | EIIS §1 required; enables Copilot/Cursor/OpenCode auto-discovery; §5 frontmatter required | Create with full §5 YAML frontmatter + overview content |
| GAP-002 | `.github/copilot-instructions.md` | CREATE | blocker | EIIS §1 required; primary Copilot entry; `.github/` dir exists | Create pointer file referencing `AGENTS.md` |
| GAP-003 | `agent.md` | CREATE | blocker | EIIS §1 required; always-loaded entry ≤1000 tokens; referenced by `install.sh` host dispatch | Create compact entry with P0 rules, cycle, skill routing table |
| GAP-004 | `install.sh` | CREATE | blocker | EIIS §1+§2 required; meta-installer needs uniform interface; existing `tools/spectra-init.sh` has incompatible interface | Create new root installer implementing full EIIS §2 contract; delegate to existing tools/ for project-analysis features |
| GAP-005 | `schemas/install.manifest.v1.json` | CREATE | blocker | EIIS §3 schema must be committed; `install.sh` references it | Create JSON Schema draft 2020-12 per §3 spec |
| GAP-006 | `INSTALL.md` | CREATE | major | EIIS §1 required; human cross-host install guide | Create covering both EIIS `install.sh` and direct `tools/spectra-init.sh` paths |
| GAP-007 | `DESIGN-RATIONALE.md` | CREATE | major | EIIS §1 required; research→decision mapping | Create summarizing key architectural decisions (references existing `docs/research/SYNTHESIS.md`) |
| GAP-008 | `SPECTRA.md` (root) | CREATE | major | EIIS §1 requires `<EIDOLON>.md` at root; full spec lives at `docs/spectra-methodology/SPECTRA.md` | Create thin root stub that re-exports the canonical path; does NOT duplicate methodology content |
| GAP-009 | `hosts/claude-code.md` | CREATE | major | EIIS §1 required per-host wiring doc | Create: install steps, config locations, verification, troubleshooting |
| GAP-010 | `hosts/copilot.md` | CREATE | major | EIIS §1 required per-host wiring doc | Create: install steps, config locations, verification, troubleshooting |
| GAP-011 | `hosts/cursor.md` | CREATE | major | EIIS §1 required per-host wiring doc | Create: install steps, config locations, verification, troubleshooting |
| GAP-012 | `hosts/opencode.md` | CREATE | major | EIIS §1 required per-host wiring doc | Create: install steps, config locations, verification, troubleshooting |
| GAP-013 | `evals/canary-missions.md` | CREATE | major | EIIS §1 requires ≥1 smoke mission | Create 3 smoke missions: simple feature spec, brownfield analysis, ambiguous request |
| GAP-014 | `skills/spectra/SKILL.md` | CREATE | major | EIIS §1 requires ≥1 `skills/<phase>/SKILL.md`; existing routing card at `docs/spectra-methodology/SKILL.md` | Create `skills/spectra/SKILL.md` with content adapted from existing routing card (additive, does not touch original) |
| GAP-015 | `templates/planning-artifact.md` | CREATE | minor | EIIS §1 requires ≥1 `templates/<artifact>.md`; full templates at `docs/spectra-methodology/templates.md` | Create pointer template file referencing the canonical source |
| GAP-016 | `CLAUDE.md` | PATCH | major | Missing consumer-project `@agents/spectra/agent.md` pointer and installed-usage section required by EIIS §4 | Append "Consumer Project Usage" section at end of file |

## Methodology-Adjacent Items (FLAG — no edit without approval)

| Item | Reason |
|------|--------|
| `docs/spectra-methodology/SPECTRA.md` | Full methodology — not moved, not modified. Root `SPECTRA.md` (GAP-008) is a pointer only. |
| `docs/spectra-methodology/SKILL.md` | Routing card — not modified. New `skills/spectra/SKILL.md` (GAP-014) adapts it additively. |
| `docs/spectra-methodology/templates.md` | Templates — not modified. New `templates/planning-artifact.md` (GAP-015) is a pointer. |
| `tools/spectra-init.sh` and `tools/lib/` | Existing installer — not touched. New `install.sh` (GAP-004) is an independent EIIS contract implementation. |

## Severity Summary

- **Blockers** (breaks install contract or consumer dispatch): GAP-001, GAP-002, GAP-003, GAP-004, GAP-005
- **Majors** (breaks consumer experience or violates EIIS §1): GAP-006 through GAP-014
- **Minors** (quality of life): GAP-015
- **Patches** (existing file needs content): GAP-016
