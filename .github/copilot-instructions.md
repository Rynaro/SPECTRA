# GitHub Copilot — SPECTRA methodology

> Primary custom-instructions entry for GitHub Copilot. The authoritative
> rule set is `AGENTS.md` at repo root (open standard, also loaded by Cursor
> and OpenCode). This file is a minimal pointer for Copilot hosts that do
> not yet honor `AGENTS.md`.

## What SPECTRA is

SPECTRA (Strategic Specification through Deliberate Reasoning) is a vendor-agnostic cognitive architecture for AI agents that plan before they act. It transforms ambiguous intent into executable specifications through a structured eight-phase reasoning cycle, producing dual-format output (Markdown + YAML/JSON) that works with any LLM, IDE, or stack.

## Non-negotiable rules

1. READ-ONLY during all SPECTRA phases — no code, no mutations.
2. Dual-format output: human-readable Markdown + agent-executable YAML/JSON.
3. Never skip CLARIFY — parse WHO, WHAT, WHY, CONSTRAINTS first.
4. Complexity ≥7/12 → extended thinking (2× token budget).
5. Confidence <85% at Assemble → return to Refine (max 3 cycles).

## Phase pipeline

| Phase | Purpose | Skill file |
|-------|---------|-----------|
| CLARIFY | Disambiguate intent + gather context | `docs/spectra-methodology/SPEC.md` |
| S — Scope | Classify intent, score complexity, set boundaries | `docs/spectra-methodology/SPEC.md` |
| P — Pattern | Survey codebase, catalog patterns | `docs/spectra-methodology/SPEC.md` |
| E — Explore | Generate 3–5 hypotheses, score on 7-dim rubric | `docs/spectra-methodology/scoring.md` |
| C — Construct | Write the specification | `docs/spectra-methodology/templates.md` |
| T — Test | 6-layer verification | `docs/spectra-methodology/scoring.md` |
| R — Refine | Reflexion-style self-critique | `docs/spectra-methodology/SPEC.md` |
| A — Assemble | Finalize + persist dual-format artifact | `docs/spectra-methodology/templates.md` |

## Full spec

`docs/spectra-methodology/SPEC.md`
