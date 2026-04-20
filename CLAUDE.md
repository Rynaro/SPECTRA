# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

SPECTRA is a **methodology repository**, not a software project. It contains documentation, research, examples, and one shell tool — no application code, no build system, no tests, no dependencies. Think of it like a published specification (similar to Agile or TOGAF) for how AI agents should plan before they execute.

The core cycle: **CLARIFY → S(cope) → P(attern) → E(xplore) → C(onstruct) → T(est) → R(efine) → A(ssemble) → PERSIST/ADAPT**

## Repository Layout

- `docs/spectra-methodology/` — Core methodology files (SPECTRA.md is the primary document, scoring.md has all rubrics, templates.md has output formats, SKILL.md is a quick-reference card)
- `docs/research/` — Theoretical foundations, academic references, and the brownfield installation guide (RETROFIT.md)
- `docs/benchmarks/` — Evaluation framework (data collection in progress)
- `examples/` — Worked examples (Rails, Node.js) and anti-patterns
- `tools/spectra-init.sh` — Bash script that analyzes a project and generates SPECTRA adaptation prompts

## Tools

The only executable is `tools/spectra-init.sh` (bash 4+, standard coreutils). Run it at a target project root:

```bash
bash tools/spectra-init.sh /path/to/project
```

It outputs `spectra-project-profile.md` and `spectra-adaptation-prompt.md` in the target project root.

## Contribution Rules

- This is a methodology, not a codebase. Contributions must strengthen the intellectual framework.
- No implementation code — SPECTRA is implementation-agnostic.
- No vendor-specific instructions in core methodology docs.
- Architecture changes require research backing or significant case study data.
- Every claim needs evidence ("This is better" needs a "because").
- Keep core methodology vendor-agnostic — no specific model names.
- Maintain version consistency across all methodology files (currently v4.2.0).
- Style: be precise, every word earns its place.

## Writing Conventions

- The methodology uses a specific hierarchy: THEME → PROJECT → FEATURE → STORY → TASK. Never use "Epic" — always "Project".
- Stories use timeboxes (1d/2d/3d/5d/8d), never story points. Stories >8d must be decomposed.
- Acceptance criteria always use GIVEN/WHEN/THEN format.
- Plans are always dual-format: human-readable Markdown + agent-executable structured data (YAML/JSON).
- The ASCII diagrams in docs are alignment-sensitive — edit carefully.

## License

CC BY-SA 4.0 — share improvements under the same terms.

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
