# Wiring SPECTRA into GitHub Copilot

## 1. Install

```bash
# EIIS Eidolons framework
bash install.sh --hosts copilot

# Direct SPECTRA adoption (also creates .github/agents/ entry)
bash tools/spectra-init.sh /path/to/your/project
# then select vendor: copilot
```

## 2. Config

Copilot reads `.github/copilot-instructions.md` as custom instructions.
The installer creates or appends this file automatically:

```markdown
## SPECTRA Planning Agent

The SPECTRA planning agent is installed at `.eidolons/spectra/`.
Entry point: `.eidolons/spectra/agent.md`
Full spec: `.eidolons/spectra/SPECTRA.md`
```

**Copilot agent mode** (`.github/agents/`):
```
.github/agents/spectra-planner.agent.md
```

**EIIS install creates:**
```
.eidolons/spectra/agent.md
.github/copilot-instructions.md   ← created or appended
```

## 3. Verify

In a GitHub Copilot Chat or Copilot Workspace session:

```
Using the SPECTRA methodology at .eidolons/spectra/agent.md, what phases
should I run for a complex multi-service feature?
```

Expected: Copilot describes the CLARIFY → S → P → E → C → T → R → A cycle
and references the installed files.

## 4. Troubleshooting

**Instructions not loading:** Verify `.github/copilot-instructions.md` exists
and references `.eidolons/spectra/agent.md`. Copilot must have "custom instructions"
enabled (Settings → Copilot → Custom Instructions).

**File size limits:** If Copilot truncates the instructions, keep only the
`agent.md` pointer in `.github/copilot-instructions.md`. Load `SPECTRA.md`
on demand by pasting its path into the chat.

**Workspace agent not found:** Copilot Workspace agent mode requires
`.github/agents/spectra-planner.agent.md`. Run the direct installer
(`tools/spectra-init.sh`, select `copilot`, select `agent` mode) to create it.
