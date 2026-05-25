# Wiring SPECTRA into Claude Code

## 1. Install

```bash
# EIIS Eidolons framework — installs to ./.eidolons/spectra/
bash install.sh --hosts claude-code

# Direct SPECTRA adoption — project analysis + adaptation prompts
bash tools/spectra-init.sh /path/to/your/project
```

## 2. Config

After EIIS install, Claude Code finds SPECTRA via your project's `CLAUDE.md`.
The installer appends this pointer automatically:

```markdown
## SPECTRA Planning Agent

`@.eidolons/spectra/agent.md`
```

**Claude Code agent mode** (direct install):
```
.claude/agents/spectra-planner.md
```

**Claude Code skill mode** (direct install):
```
.claude/skills/spectra-methodology/
```

**EIIS install path:**
```
.eidolons/spectra/agent.md          ← always-loaded entry
.eidolons/spectra/SPEC.md           ← full methodology
.eidolons/spectra/skills/planning.md ← quick routing card
.eidolons/spectra/scoring.md        ← rubrics
.eidolons/spectra/templates.md      ← output formats
```

## 3. Verify

In Claude Code, run:

```
@.eidolons/spectra/agent.md What is your role and what are your hard constraints?
```

Expected: the agent identifies as SPECTRA planning specialist, states the READ-ONLY
constraint, and describes the CLARIFY → S → P → E → C → T → R → A cycle.

Or for direct install:
```
@spectra-planner What phases do you run for a complex multi-service feature?
```

## 4. Troubleshooting

**Agent not found:** Verify `.eidolons/spectra/agent.md` exists. Re-run `bash install.sh --force`.

**Wrong file loaded:** Check `CLAUDE.md` contains the `@.eidolons/spectra/agent.md` pointer.
The pointer must be in `CLAUDE.md` at the project root, not only in `.claude/`.

**Skill mode not activating:** Confirm SPECTRA files are at `.claude/skills/spectra-methodology/`
(direct install) or `.eidolons/spectra/` (EIIS install). See `INSTALL.md` for the full path matrix.

**Token budget:** `agent.md` is ≤1000 tokens by design. If Claude Code truncates context,
load `SPEC.md` explicitly: `@.eidolons/spectra/SPEC.md`.
