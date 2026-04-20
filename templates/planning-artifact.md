---
artifact: planning-artifact
version: 4.2.0
---

# Planning Artifact — SPECTRA Output Template

SPECTRA produces dual-format output: human-readable Markdown + agent-executable
structured data (YAML/JSON). Plans are never code.

## Output Contract

Every SPECTRA Assemble phase produces:
1. **Markdown spec** — human-readable, reviewer-friendly
2. **YAML/JSON block** — agent-executable structured data

## Full Template Library

The complete template library (one template per phase artifact) is at:

[`docs/spectra-methodology/templates.md`](../docs/spectra-methodology/templates.md)

Templates include:
- Scope artifact (intent classification, complexity score, boundaries)
- Pattern catalog (existing patterns, anti-patterns)
- Hypothesis table (3–5 hypotheses × 7-dimension rubric)
- Feature Story (GIVEN/WHEN/THEN acceptance criteria)
- Test verification checklist (6-layer)
- Refinement log
- Final assembly artifact (dual-format)

---

*SPECTRA v4.2.0*
