# EIIS-1.0 Conformance Plan — SPECTRA

Generated: 2026-04-20

## 1. Summary

SPECTRA v4.2.0 is a mature methodology repo with comprehensive content in `docs/`, a sophisticated multi-module installer in `tools/`, and solid README/CHANGELOG. The install surface (EIIS §1) is entirely absent: no root `agent.md`, no `AGENTS.md`, no `install.sh`, no `hosts/`, no `evals/`, no `schemas/`, no `skills/` structure, and `CLAUDE.md` lacks the consumer-project pointer.

After this plan executes, the repo will have a complete EIIS-1.0 install surface: a compact root `agent.md` (~350 tokens), an `AGENTS.md` with §5 frontmatter enabling auto-discovery, a new root `install.sh` implementing the EIIS §2 contract, four `hosts/*.md` wiring docs, a canary missions eval, a `skills/spectra/SKILL.md`, a `templates/planning-artifact.md`, and the JSON Schema.

All 16 gaps are addressed. The existing methodology content in `docs/spectra-methodology/` is NOT touched. The existing `tools/spectra-init.sh` installer is NOT touched. Only additive new files plus one append to `CLAUDE.md`.

**Explicit out of scope:** Moving or modifying `docs/spectra-methodology/SPECTRA.md`, `SKILL.md`, `scoring.md`, or `templates.md`. Changing `tools/spectra-init.sh` or its modules. Patching `README.md` (it already satisfies EIIS §1).

## 2. File Change List

### GAP-001: CREATE `AGENTS.md`

YAML frontmatter per §5: `name: spectra`, `version: 4.2.0`, `methodology: SPECTRA`, `methodology_version: 4.2.0`, `role: planning-specialist — transforms ambiguous intent into executable specifications`, `handoffs: upstream: [], downstream: []`. Body: one-paragraph description from README, the cycle diagram, P0 non-negotiable rules (read-only, dual-format plans, ≤3 clarification questions, max 3 refinement cycles), skill routing table, install pointer.

### GAP-002: CREATE `.github/copilot-instructions.md`

Minimal Copilot pointer per template. One-paragraph SPECTRA summary, P0 rules list, phase pipeline table with skill file references, link to `AGENTS.md` as primary authority, link to `docs/spectra-methodology/SPECTRA.md` for full spec.

### GAP-003: CREATE `agent.md`

Always-loaded entry point. YAML frontmatter with `name`, `version`, `methodology`, `role`. Content: activation criteria (complexity ≥7/12, multi-component, ambiguous), the ASCII cycle diagram, 6 P0 hard constraints, on-demand skill routing table (4 rows), consumer-project install line. Target: ~250 words body + frontmatter ≈ 300 tokens (well under 1000 limit).

### GAP-004: CREATE `install.sh`

New root-level installer implementing the full EIIS §2 contract. Key behaviors:
- Parse all 8 flags: `--target`, `--hosts`, `--force`, `--dry-run`, `--non-interactive`, `--manifest-only`, `--version`, `-h`/`--help`
- Auto-detect consumer hosts by directory/file presence: `.claude/` or `CLAUDE.md` → `claude-code`; `.github/` → `copilot`; `.cursor/` or `.cursorrules` → `cursor`; `.opencode/` → `opencode`
- Copy Eidolon files from `SCRIPT_DIR/` to `$TARGET/`: `agent.md`, `SPECTRA.md`→`SPECTRA.md`, `docs/spectra-methodology/SPECTRA.md`→`SPECTRA.md`, `docs/spectra-methodology/SKILL.md`→`SKILL.md`, `docs/spectra-methodology/scoring.md`→`scoring.md`, `docs/spectra-methodology/templates.md`→`templates.md`
- Create consumer-side dispatch files per host (CLAUDE.md append, .github/copilot-instructions.md, .cursor/rules/spectra.mdc, .opencode/agents/spectra.md)
- Write `$TARGET/install.manifest.json` with all §3 required fields
- Print BPE-approx token count: `wc -w agent.md | awk '{printf "%d", $1/0.75}'`
- Print smoke-test verification prompt
- Exit codes: 0=success, 2=bad args, 3=existing install (non-interactive), 4=token budget exceeded (non-interactive)
- Uses only relative paths internally; no external dependencies beyond bash 4+ and standard coreutils
- Does NOT call or wrap `tools/spectra-init.sh` — the two installers serve different purposes

### GAP-005: CREATE `schemas/install.manifest.v1.json`

JSON Schema draft 2020-12 exactly matching §3 specification: required fields `eidolon`, `version`, `methodology`, `installed_at`, `target`, `hosts_wired`, `files_written`; optional `handoffs_declared`, `token_budget`, `security`. Pattern constraints per spec: eidolon slug `^[a-z][a-z0-9-]*$`, version semver `^\d+\.\d+\.\d+$`.

### GAP-006: CREATE `INSTALL.md`

Human cross-host install guide covering: (1) EIIS Eidolons framework path via `bash install.sh`, (2) direct SPECTRA adopter path via `bash tools/spectra-init.sh`. Sections: Prerequisites, Quick Install (EIIS), Quick Install (Direct), Manual Installation (per-host table), Options Reference, Verification, Troubleshooting. Notes that the two paths are complementary, not competing.

### GAP-007: CREATE `DESIGN-RATIONALE.md`

Maps key architectural decisions to research evidence. Sections: (1) Plan/Execute Separation — evidence: universal pattern in Cursor/Claude Code/Copilot; (2) Structured Clarification — prevents 40%+ wasted effort; (3) 3–5 Hypotheses — PlanSearch (~2×), Miller's Law; (4) 7-Dimension Rubric — extends Tree of Thoughts; (5) 6-Layer Verification; (6) Reflexion Refinement (max 3 cycles); (7) Read-Only Constraint; (8) Dual-Format Artifacts. References `docs/research/SYNTHESIS.md` and `docs/research/THEORY.md` for depth.

### GAP-008: CREATE `SPECTRA.md` (root)

Thin pointer stub. Frontmatter: `name: spectra`, `version: 4.2.0`. One-sentence description. A clear redirect: "The authoritative SPECTRA methodology document is at `docs/spectra-methodology/SPECTRA.md`." Section links: SKILL.md, scoring.md, templates.md, examples/. This satisfies the EIIS §1 `<EIDOLON>.md` at root requirement without duplicating content or touching the original.

### GAP-009–012: CREATE `hosts/{claude-code,copilot,cursor,opencode}.md`

Per-host wiring docs using the minimal skeleton (4 sections: Install, Config, Verify, Troubleshooting). Each covers: the install command, the specific config file locations for that host, a verification smoke test prompt, and common issues. claude-code.md covers `CLAUDE.md` and `.claude/agents/`. copilot.md covers `.github/copilot-instructions.md`. cursor.md covers `.cursor/rules/`. opencode.md covers `.opencode/agents/`.

### GAP-013: CREATE `evals/canary-missions.md`

Three smoke missions:
1. **Simple Feature Spec** — "Add a health check endpoint" (minimal scope, greenfield)
2. **Brownfield Analysis** — "Extend an existing user authentication system with MFA" (Pattern phase emphasis)
3. **Ambiguous Request** — "Make the app faster" (CLARIFY phase stress test, 3 clarifying questions required)
Each mission has: input prompt, expected phase activations, expected artifact shape, pass/fail criteria.

### GAP-014: CREATE `skills/spectra/SKILL.md`

Adapted from `docs/spectra-methodology/SKILL.md`. Same core content (when to activate, resource routing table) with a minor addition: explicit on-demand load instruction and reference to full skill tree. Does NOT modify the original.

### GAP-015: CREATE `templates/planning-artifact.md`

Thin pointer template: frontmatter declaring artifact type `planning-artifact`, a brief description of SPECTRA's dual-format output contract (Markdown + YAML/JSON), and a redirect to `docs/spectra-methodology/templates.md` for the full template library. Satisfies EIIS §1 ≥1 template requirement.

### GAP-016: PATCH `CLAUDE.md`

Append a new section at end of file:

```markdown
## Consumer Project Usage

After installing SPECTRA into a consumer project via `bash install.sh`, Claude Code
will find the installed agent at `agents/spectra/agent.md`. Reference it with:

```
@agents/spectra/agent.md
```

For direct SPECTRA adoption (project analysis + adaptation prompts), use:

```bash
bash tools/spectra-init.sh /path/to/project
```
```

This is a pure append — no existing content is modified.

## 3. Risk Register

| Risk | Likelihood | Mitigation |
|------|-----------|-----------|
| `install.sh` copy logic assumes files exist at expected paths; if `agent.md` not created first, copy fails | Medium | Execute order: create `agent.md` first (GAP-003), then `install.sh` (GAP-004) |
| Root `SPECTRA.md` pointer could confuse users expecting full content | Low | Clear redirect text + frontmatter disambiguation |
| `CLAUDE.md` patch may break existing formatting if append doesn't respect trailing newline | Low | Use Edit tool with explicit trailing newline; verify after write |
| `install.sh` host-detection logic for opencode not validated against actual `.opencode/` dir structure | Low | Use conservative check (`-d ".opencode"`) with `--dry-run` verification in Phase 6 |
| Branch creation fails if local `main` has uncommitted changes | Low | Audit showed clean working tree at conversation start |

## 4. Token Budget Estimate

- `agent.md` draft: ~250 words body + ~30 words frontmatter = ~280 words → **~373 tokens** (280/0.75)
- Consumer-side always-loaded impact: `agent.md` (~373) + CLAUDE.md pointer line (~15) = **~390 tokens** added to consumer context
- Well within EIIS §6 limit of 1,000 tokens

## 5. Rejected Alternatives

**Alt A: Wrap `tools/spectra-init.sh` as the EIIS `install.sh`**
The existing installer is a multi-module bash tool for project analysis, stack detection, and adaptation prompt generation. Wrapping it with EIIS flags would create a confusing hybrid that can't cleanly implement `--manifest-only`, `--dry-run`, or `--non-interactive` without substantial refactor. Rejected: creates tight coupling between two distinct installation purposes.

**Alt B: Move `docs/spectra-methodology/SPECTRA.md` to repo root**
Would satisfy EIIS §1 `<EIDOLON>.md` cleanly but breaks the existing `docs/` structure documented in `CLAUDE.md`, `README.md`, and all cross-references. The `tools/assets/methodology/` bundle would also need updating. Rejected: blast radius too large for a conformance patch.

**Alt C: Use symlinks for `SPECTRA.md`, `skills/`, `templates/`**
Clean solution but symlinks are platform-specific and may break on Windows consumers. Rejected: portability requirement.

## 6. Execution Order

1. Create directories: `hosts/`, `evals/`, `skills/spectra/`, `templates/`, `schemas/`
2. GAP-003: `agent.md` (must exist before install.sh references it)
3. GAP-001: `AGENTS.md`
4. GAP-002: `.github/copilot-instructions.md`
5. GAP-008: `SPECTRA.md` (root)
6. GAP-005: `schemas/install.manifest.v1.json`
7. GAP-014: `skills/spectra/SKILL.md`
8. GAP-015: `templates/planning-artifact.md`
9. GAP-009–012: `hosts/*.md`
10. GAP-013: `evals/canary-missions.md`
11. GAP-007: `DESIGN-RATIONALE.md`
12. GAP-006: `INSTALL.md`
13. GAP-004: `install.sh` (last — references all other created files)
14. GAP-016: PATCH `CLAUDE.md`
15. Update `CHANGELOG.md`
