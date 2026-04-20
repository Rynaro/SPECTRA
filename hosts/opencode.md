# Wiring SPECTRA into OpenCode

## 1. Install

```bash
# EIIS Eidolons framework (requires .opencode/ dir to exist in consumer project)
bash install.sh --hosts opencode
```

## 2. Config

OpenCode reads agent definitions from `.opencode/agents/`. The installer creates:

```
.opencode/agents/spectra.md
```

The agent file content:

```markdown
# SPECTRA — Planning Specialist

Entry point: `agents/spectra/agent.md`
Full spec: `agents/spectra/SPECTRA.md`

SPECTRA produces specifications, never code. Activate for tasks with complexity ≥7/12.
```

**EIIS install creates:**
```
agents/spectra/agent.md
.opencode/agents/spectra.md      ← dispatch file (if .opencode/ exists)
```

## 3. Verify

In OpenCode:

```
@spectra What are your hard constraints?
```

Expected: the agent identifies as SPECTRA planning specialist and lists the
6 P0 constraints: READ-ONLY, dual-format output, CLARIFY-first, extended
thinking at ≥7/12, max 3 refinement cycles, spec-not-code.

## 4. Troubleshooting

**Agent not detected:** OpenCode auto-discovery requires the `.opencode/`
directory to exist before running `install.sh`. Create it first:

```bash
mkdir .opencode
bash install.sh --hosts opencode
```

**File not created:** Verify `.opencode/agents/spectra.md` was written.
Re-run with `--force`: `bash install.sh --hosts opencode --force`.

**Entry point not loading:** Confirm `agents/spectra/agent.md` exists in your
consumer project. If the EIIS install was run from a different working directory,
re-run: `bash install.sh --target ./agents/spectra --hosts opencode`.
