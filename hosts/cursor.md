# Wiring SPECTRA into Cursor

## 1. Install

```bash
# EIIS Eidolons framework (requires .cursor/ dir to exist in consumer project)
bash install.sh --hosts cursor

# Direct SPECTRA adoption
bash tools/spectra-init.sh /path/to/your/project
# then select vendor: cursor
```

## 2. Config

Cursor loads rules from `.cursor/rules/*.mdc`. The installer creates:

```
.cursor/rules/spectra.mdc
```

The rule file content:

```markdown
---
description: SPECTRA planning methodology
alwaysApply: false
---

# SPECTRA — Planning Specialist

Entry point: `.eidolons/spectra/agent.md`
Full spec: `.eidolons/spectra/SPECTRA.md`

SPECTRA produces specifications, never code. Activate for tasks with complexity ≥7/12.
```

**Cursor agent mode** (direct install):
```
.cursor/agents/spectra-planner.mdc
```

## 3. Verify

In Cursor Chat:

```
@spectra-planner What is the SPECTRA cycle? List all phases.
```

Or referencing the rule directly:

```
Using SPECTRA (see .cursor/rules/spectra.mdc), outline the planning phases
for adding OAuth2 to an existing REST API.
```

Expected: the agent describes the full CLARIFY → S → P → E → C → T → R → A
cycle and states the READ-ONLY constraint.

## 4. Troubleshooting

**Rule not loading:** Check `.cursor/rules/spectra.mdc` exists. Cursor requires
`.mdc` extension for rules. Verify "Rules for AI" is enabled in
Cursor Settings → Features → Rules for AI.

**Agent not found in @mentions:** Cursor agent mode requires `.cursor/agents/`.
Run `bash tools/spectra-init.sh`, select `cursor` + `agent` mode.

**`.cursor/` not detected:** The EIIS installer checks for `.cursor/` directory
or `.cursorrules` file. If neither exists in your project, the cursor dispatch
file is skipped. Create `.cursor/` first, then re-run `bash install.sh --hosts cursor`.

**Windows path separators:** Run bash via WSL or Git Bash; forward slashes
are used internally by the installer.
