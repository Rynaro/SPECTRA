---
name: spectra-methodology
description: "SPECTRA v4 — vendor-agnostic specification and planning methodology for AI agents."
metadata:
  version: 4.2.0
---

# SPECTRA Methodology — Quick Reference

Use SPECTRA when your AI agent needs to plan before it acts.

## When to Activate

- Complex features (complexity ≥7/12)
- Multi-component or multi-service changes
- Ambiguous requirements needing structured decomposition
- Specification refinement needing deliberate process
- Any task where "just start coding" would likely require significant rework

## On-Demand Load Instructions

Load this skill first, then escalate to the full spec as required:

```
@skills/spectra/SKILL.md                    ← routing card (this file)
@docs/spectra-methodology/SPECTRA.md        ← full cognitive architecture
@docs/spectra-methodology/scoring.md        ← rubrics and matrices
@docs/spectra-methodology/templates.md      ← output formats
```

After installing into a consumer project:
```
@agents/spectra/SKILL.md                    ← routing card
@agents/spectra/SPECTRA.md                  ← full spec
```

## Resources

| Need | Load |
|------|------|
| Full cognitive architecture | `docs/spectra-methodology/SPECTRA.md` |
| Scoring matrices + rubrics | `docs/spectra-methodology/scoring.md` |
| Output formats per phase | `docs/spectra-methodology/templates.md` |
| Worked examples | `examples/` |
| Theoretical foundations | `docs/research/THEORY.md` |
| Brownfield installation | `docs/research/RETROFIT.md` |

---

*SPECTRA v4.2.0*
