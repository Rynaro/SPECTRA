# SPECTRA

**A vendor-agnostic planning methodology for AI agents that think before they code.**

[![SPECTRA v4.2](https://img.shields.io/badge/methodology-SPECTRA_v4.2-6366f1)](docs/spectra-methodology/SPEC.md)
[![License: CC BY-SA 4.0](https://img.shields.io/badge/license-CC_BY--SA_4.0-green)](LICENSE)
[![Research: 15+ papers](https://img.shields.io/badge/research-15%2B_papers-blue)](docs/research/REFERENCES.md)
[![Benchmarks: Coming Soon](https://img.shields.io/badge/benchmarks-coming_soon-orange)](docs/benchmarks/README.md)

---

> ### 📊 Benchmarks Are Coming
>
> SPECTRA's evaluation framework is designed with peer-reviewable rigor: **3-layer evaluation architecture**, pre-registered hypotheses, triple assessment (human expert + LLM-as-Judge + automated structural checks), and statistical methodology (N≥30, Cohen's d effect sizes, Bonferroni-corrected significance).
>
> **Instrument development is complete. Data collection is underway.** Results will be published in [`docs/benchmarks/`](docs/benchmarks/README.md) as they become available.
>
> 🤝 **Want to accelerate this?** Every real-world [case study submission](https://github.com/Rynaro/SPECTRA/issues/new?template=case_study_submission.md) is a benchmark data point.

---

## The Problem

Every major AI coding tool — Cursor, Claude Code, GitHub Copilot — has independently converged on the same architecture: **separate planning from execution**. The evidence is strong:

- Self-Planning Code Generation: **25.4% improvement** in Pass@1 (Jiang et al., ASE 2024)
- PlanSearch: diversity at the plan level **nearly doubles** performance (Wang et al., 2024)
- Reflexion: structured self-critique achieves **91% Pass@1** on HumanEval (Shinn et al., NeurIPS 2023)

Yet every implementation is locked inside a proprietary tool. Switch editors, switch LLMs, build your own agents — you start from zero.

**SPECTRA is the methodology extracted from the pattern.** It's the playbook, not the player.

## What SPECTRA Is

**S**cope → **P**attern → **E**xplore → **C**onstruct → **T**est → **R**efine → **A**ssemble

A cognitive architecture that codifies how the best commercial tools think before they act, distilled into a portable methodology that works with **any LLM, any IDE, any stack**.

```
         ┌── CLARIFY (disambiguate + gather context) ──┐
         ▼                                             │
  S → P → E → C → T → R ─┬→ A (confidence ≥85%)        │
                         └→ R (refine, max 3)          │
         ▼                                             │
         └── PERSIST (artifact storage) + ADAPT ───────┘
```

### What Makes It Different

| Capability | Raw ReAct | Cursor Plan | Claude Code Plan | **SPECTRA** |
|------------|----------|-------------|-----------------|-------------|
| Plan/execute separation | ✗ | ✓ | ✓ | ✓ |
| Structured clarification | ✗ | Partial | Partial | **✓ (protocol)** |
| Plan diversity (3–5 hypotheses) | ✗ | ✗ | ✗ | **✓** |
| Weighted scoring rubric | ✗ | ✗ | ✗ | **✓ (7-dim)** |
| Multi-layer verification | ✗ | ✗ | Reasoning only | **✓ (6 layers)** |
| Reflexion-style refinement | ✗ | ✗ | ✗ | **✓** |
| Adaptive replanning | ✗ | ✗ | ✗ | **✓** |
| Failure taxonomy | ✗ | ✗ | ✗ | **✓ (8 modes)** |
| Theoretical foundations | ✗ | ✗ | ✗ | **✓ (formal)** |
| Vendor-agnostic | ✗ | ✗ (Cursor) | ✗ (Anthropic) | **✓** |
| Open methodology | ✗ | ✗ | ✗ | **✓** |
| Stack adaptation tooling | ✗ | ✗ | ✗ | **✓** |

### What SPECTRA Is Not

- **Not a framework or library.** No `pip install`. It's a methodology — like Agile or TOGAF, but for AI planning agents.
- **Not vendor-locked.** Works with Claude, GPT, Gemini, Llama, Mistral, or whatever comes next.
- **Not an agent.** SPECTRA describes *how an agent should think about planning*. Your agent, your implementation.

---

## Quick Start

**One command to install SPECTRA into your project:**

```bash
bash tools/spectra-init.sh
# or from a clone:
git clone https://github.com/Rynaro/SPECTRA.git
bash SPECTRA/tools/spectra-init.sh /path/to/your/project
```

The installer will:
1. **Analyze your project** — detect languages, frameworks, databases, CI systems, existing conventions
2. **Auto-detect your LLM tool** — Claude Code, GitHub Copilot, or Cursor
3. **Ask your preference** — **Agent** mode (dedicated `@spectra-planner` agent) or **Skill** mode (on-demand reference). See [SKILL.md](docs/spectra-methodology/SKILL.md) for the difference.
4. **Install files** — create `.spectra/` working directory + place SPECTRA into your LLM tool
5. **Generate prompts** — create project profile and adaptation prompt in `.spectra/setup/`

The entire flow is **interactive** (2–3 minute setup) and **self-contained** (no manual file copying).

**What gets created:**

```
.spectra/
├── plans/                          # Your planning artifacts
└── setup/
    ├── project-profile.md          # Detected tech stack
    ├── adaptation-prompt.md        # Paste this into any LLM
    └── spectra-conventions.md      # Stub (fill after running prompt)

.claude/ / .github/ / .cursor/      # Vendor-specific directories
├── agents/spectra-planner.md       # (if Agent mode)
└── skills/spectra-methodology/     # (if Skill mode)
```

**Next step:** Paste `adaptation-prompt.md` into your LLM (Claude, GPT, Gemini, Llama, etc.) to generate conventions tailored to your codebase. Save the output to `spectra-conventions.md`.

**For automation, CI, or advanced usage,** see [Full Installation Guide](#full-installation-guide) below.

---

## Full Installation Guide

### Interactive Mode (Default)

Run the installer and follow the prompts:

```bash
bash tools/spectra-init.sh
```

The installer will guide you through:

1. **Project analysis** — Detects your tech stack (languages, frameworks, test suites, CI/CD, architecture patterns, existing convention files)
2. **Vendor detection** — Identifies installed LLM tools (Claude Code, GitHub Copilot, Cursor) or prompts for manual selection
3. **Mode selection** — Choose between:
   - **Agent mode:** SPECTRA as a dedicated `@spectra-planner` agent you invoke explicitly
   - **Skill mode:** SPECTRA as an on-demand skill/rule loaded automatically by your LLM
4. **Installation confirmation** — Shows exactly what will be created, then installs files

### Non-Interactive Mode (CI/Automation)

For GitHub Actions, GitLab CI, or other automation, use environment variables:

```bash
SPECTRA_VENDOR=claude \
SPECTRA_MODE=skill \
SPECTRA_YES=1 \
bash tools/spectra-init.sh /path/to/project
```

| Variable | Values | Default |
|----------|--------|---------|
| `SPECTRA_VENDOR` | `claude`, `copilot`, `cursor` | Auto-detect |
| `SPECTRA_MODE` | `agent`, `skill` | Prompt user |
| `SPECTRA_YES` | `1` or unset | Prompt user |

**GitHub Actions example:**

```yaml
- name: Install SPECTRA
  env:
    SPECTRA_VENDOR: claude
    SPECTRA_MODE: skill
    SPECTRA_YES: 1
  run: |
    bash tools/spectra-init.sh ${{ github.workspace }}
    git config user.email "spectra@example.com"
    git config user.name "SPECTRA Installer"
    git add .spectra/ .claude/
    git commit -m "chore: Install SPECTRA" || echo "No changes to commit"
    git push
```

### File Placement Matrix

| Vendor | Agent Mode | Skill Mode |
|--------|-----------|-----------|
| **Claude Code** | `.claude/agents/spectra-planner.md` | `.claude/skills/spectra-planning/SKILL.md` |
| **GitHub Copilot** | `.github/agents/spectra-planner.agent.md` | `.github/instructions/spectra-planning.instructions.md` |
| **Cursor** | `.cursor/agents/spectra-planner.mdc` | `.cursor/rules/spectra-methodology.mdc` (+ resources/) |

All modes also create:
- `.spectra/plans/` — for your planning artifacts (YAML, JSON, Markdown)
- `.spectra/setup/` — project profile, adaptation prompt, conventions stub

**Want to customize the installer or add support for a new vendor/LLM tool?** See [tools/README.md](tools/README.md) for architecture, extensibility, and contribution guide.

### Greenfield vs Brownfield

| Scenario | Installer Behavior |
|----------|-------------------|
| **Greenfield** (new project, no conventions) | Detects your tech stack. Adaptation prompt generates conventions from framework defaults and best practices. |
| **Brownfield** (existing project, has `.cursorrules`, `CLAUDE.md`, etc.) | Detects your stack *and* existing conventions. Adaptation prompt creates new conventions grounded in your codebase. See [RETROFIT.md](docs/research/RETROFIT.md) for the full brownfield protocol. |

---

## After Installation

1. **Review** `.spectra/setup/project-profile.md` — Verify detected languages, frameworks, and patterns are correct
2. **Generate conventions** — Paste `.spectra/setup/adaptation-prompt.md` into your preferred LLM (Claude, GPT, Gemini, Llama, etc.)
3. **Save output** — Copy the LLM's response into `.spectra/setup/spectra-conventions.md`
4. **Start planning** — Use SPECTRA for your next feature. Invoke `@spectra-planner` (Agent mode) or reference the skill (Skill mode)

For a detailed walkthrough of the SPECTRA planning cycle, see [SPEC.md](docs/spectra-methodology/SPEC.md).

---

### Read the Methodology

| Start Here | Then | Deep Dives |
|------------|------|------------|
| [**SPEC.md**](docs/spectra-methodology/SPEC.md) | [scoring.md](docs/spectra-methodology/scoring.md) | [THEORY.md](docs/research/THEORY.md) |
| Full cognitive architecture | Rubrics, matrices, validation | Decision theory, information theory, cognitive science |

---

## Repository Structure

Organized by **what you need to do**:

```
SPECTRA/
│
├── 📖 docs/spectra-methodology/   USE: Learn and apply the methodology
│   ├── SPEC.md                     Core cognitive architecture (start here)
│   ├── SKILL.md                    Quick-reference routing card
│   ├── scoring.md                  All rubrics, matrices, validation criteria
│   └── templates.md                Copy-paste output formats per phase
│
├── 🔬 docs/research/             USE: Understand the evidence base
│   ├── REFERENCES.md               15+ papers + commercial tool analysis
│   ├── SYNTHESIS.md                 Evidence → design decision mapping
│   ├── THEORY.md                   Formal theoretical foundations (PhD-level)
│   └── RETROFIT.md                 Brownfield installation protocol
│
├── 📊 docs/benchmarks/           USE: Evaluate methodology effectiveness
│   └── README.md                   Evaluation framework + status
│
├── 💡 examples/                  USE: See SPECTRA in action
│   ├── rails-player-import.md      Full Rails example (origin stack)
│   ├── generic-api-feature.md      Node.js/TypeScript example
│   └── anti-patterns.md            What NOT to do (with corrections)
│
├── 🔧 tools/                    USE: Adapt SPECTRA to your project
│   └── spectra-init.sh             Project analyzer + LLM prompt generator
│
├── .github/
│   ├── CONTRIBUTING.md             How to contribute
│   └── ISSUE_TEMPLATE/
│       ├── case_study_submission.md
│       └── methodology_feedback.md
│
├── README.md                     ← You are here
├── CHANGELOG.md                  Version history
└── LICENSE                       CC BY-SA 4.0
```

---

## Origin Story

SPECTRA was developed and battle-tested on **Ruby on Rails** applications at a production SaaS company. The methodology originally used Rails conventions (FlowObjects, Repositories, ViewComponents) and company-specific agent names.

For this open-source release:
- All proprietary references replaced with generic capability classes
- Domain vocabulary made stack-agnostic
- `spectra-init.sh` created to auto-adapt to any project
- Examples provided for both Rails and Node.js stacks
- Theoretical foundations formalized with decision theory, information theory, and cognitive science

**The cognitive architecture is stack-independent.** Only the vocabulary in your stories changes. The CLARIFY → SPECTRA → PERSIST cycle works identically whether you're building Rails APIs, React frontends, Go microservices, or Rust systems.

---

## Key Architectural Decisions

Every design choice traces to evidence. Full mapping in [SYNTHESIS.md](docs/research/SYNTHESIS.md).

| Decision | Why | Evidence |
|----------|-----|---------|
| Read-only during planning | Forces problem-space thinking | Universal in Cursor, Claude Code, Copilot |
| Clarify before decompose | Prevents 40%+ wasted effort | Commercial tool analysis |
| 3–5 hypotheses | Plan diversity >> code diversity | PlanSearch (~2x); Miller's Law bounds |
| 7-dimension rubric | Structured evaluation beats intuition | Extends ToT value assessment |
| 6-layer verification | Catch flaws before execution | 10x cheaper than executing bad plans |
| Reflexion refinement | Diagnose → explain → prescribe | 91% Pass@1 (Shinn et al.) |
| Persistent artifacts | Plans survive context windows | MD + YAML + JSON triple format |
| Adaptive replanning | 3-step lookahead, not full restart | ADaPT-style efficiency |
| Failure taxonomy | Targeted remediation, not generic "refine" | 8 modes with diagnostic signals |
| Diminishing returns detection | Stop refining when marginal gain < 0.3 | Prevents token waste in cycles |

---

## Who Should Use This

- **AI agent builders** — Implementing planning in your agent? SPECTRA is the architecture.
- **Engineering leads** — Evaluating AI planning tools? SPECTRA is the benchmark.
- **Prompt engineers** — Designing planning prompts? SPECTRA's templates are battle-tested.
- **Open-source maintainers** — Building the next Aider, Cline, or Continue? SPECTRA is the methodology layer.
- **Researchers** — Studying AI planning? [THEORY.md](docs/research/THEORY.md) provides formal foundations.

## Contributing

Contributions should strengthen the methodology. See [CONTRIBUTING.md](.github/CONTRIBUTING.md).

**Most valuable:** Case studies with real-world results. Every case study becomes a benchmark data point.

## License

[CC BY-SA 4.0](LICENSE). Use SPECTRA in your products, adapt it for your team, teach it in workshops. Credit the source and share improvements under the same terms.

## Acknowledgments

SPECTRA v4 synthesizes insights from Plan-and-Solve Prompting (Wang et al.), PlanSearch (Wang et al.), Tree of Thoughts (Yao et al.), Reflexion (Shinn et al.), ADaPT (Prasad et al.), and patterns from Cursor, Claude Code, GitHub Copilot, Windsurf, Aider, Cline, Roo Code, and LangGraph. Theoretical foundations draw from Kahneman, Miller, Shannon, Sweller, and Elster. Full references in [REFERENCES.md](docs/research/REFERENCES.md).

---

*SPECTRA v4.2.0 — Strategic Specification through Deliberate Reasoning*
