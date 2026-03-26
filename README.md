# SPECTRA

**A vendor-agnostic planning methodology for AI agents that think before they code.**

[![SPECTRA v4.2](https://img.shields.io/badge/methodology-SPECTRA_v4.2-6366f1)](docs/spectra-methodology/SPECTRA.md)
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

### Install SPECTRA in Your Project

SPECTRA installs once per project — it maps the methodology's generic concepts to your codebase's actual patterns, then gets out of the way. The core planning cycle runs clean with no installation overhead per session.

**Step 1: Run the analyzer at your project root**

```bash
# Direct run
curl -sL https://raw.githubusercontent.com/Rynaro/SPECTRA/main/tools/spectra-init.sh | bash

# Or clone first
git clone https://github.com/Rynaro/SPECTRA.git
cd your-project/
bash ../SPECTRA/tools/spectra-init.sh
```

This produces two files:
- **`spectra-project-profile.md`** — Detected languages, frameworks, patterns, convention files, directory structure
- **`spectra-adaptation-prompt.md`** — Ready-to-paste LLM prompt

**Step 2: Generate your conventions file**

Paste `spectra-adaptation-prompt.md` into any LLM (Claude, GPT, Gemini, Llama, etc.) and save the output as **`spectra-conventions.md`** in your project root.

**Done.** The SPECTRA planning cycle now uses your conventions automatically as structural context.

| Scenario | What Happens |
|----------|-------------|
| **Greenfield** (new project) | `spectra-init.sh` detects your stack. The adaptation prompt creates conventions from framework defaults and best practices. |
| **Brownfield** (existing codebase) | `spectra-init.sh` detects your stack *and* any existing convention files (`.cursorrules`, `CLAUDE.md`, `AGENTS.md`, etc.). The adaptation prompt creates conventions grounded in your actual codebase. See [RETROFIT.md](docs/research/RETROFIT.md) for the full brownfield protocol. |

### Read the Methodology

| Start Here | Then | Deep Dives |
|------------|------|------------|
| [**SPECTRA.md**](docs/spectra-methodology/SPECTRA.md) | [scoring.md](docs/spectra-methodology/scoring.md) | [THEORY.md](docs/research/THEORY.md) |
| Full cognitive architecture | Rubrics, matrices, validation | Decision theory, information theory, cognitive science |

---

## Repository Structure

Organized by **what you need to do**:

```
SPECTRA/
│
├── 📖 docs/spectra-methodology/   USE: Learn and apply the methodology
│   ├── SPECTRA.md                  Core cognitive architecture (start here)
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
