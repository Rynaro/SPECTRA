# Research References

Papers, commercial tool analysis, and open-source implementations that inform SPECTRA v4.

---

## Academic Foundations

### Planning and Decomposition

| Paper | Authors | Venue | Key Finding | SPECTRA Impact |
|-------|---------|-------|-------------|----------------|
| **Plan-and-Solve Prompting** | Wang et al. | ACL 2023 | "Devise a plan, then carry it out step by step" improves reasoning over vanilla CoT | Core SPECTRA cycle: plan before execute |
| **Self-Planning Code Generation** | Jiang et al. | ASE 2024 | Explicit planning before coding yields **25.4% improvement** in Pass@1 | Validates plan-first architecture |
| **PlanSearch** | Wang et al. | 2024 | Diversity at the plan level produces better code than diversity at the code level. Nearly **2x Claude Sonnet performance** | Explore phase: observations → diverse hypotheses |
| **ADaPT** | Prasad et al. | NAACL 2024 | Recursive as-needed decomposition: attempt first, decompose only on failure | Anti-over-planning rule (complexity ≤5 skip) |
| **Agentless** | Xia et al. | 2024 | Fixed pipeline (localize → repair → validate) achieves **50.8% SWE-bench** at $0.34/issue | Validates structured pipeline over autonomous agents |

### Reasoning Architectures

| Paper | Authors | Venue | Key Finding | SPECTRA Impact |
|-------|---------|-------|-------------|----------------|
| **Chain-of-Thought Prompting** | Wei et al. | NeurIPS 2022 | Step-by-step reasoning dramatically improves LLM performance | Foundation: THINK → ACT → OBSERVE → REFLECT |
| **Tree of Thoughts** | Yao et al. | NeurIPS 2023 | Exploring multiple reasoning paths with evaluation and backtracking. **74% vs 4%** on Game of 24 | Explore phase: generate, score, select |
| **Graph of Thoughts** | Besta et al. | 2024 | Arbitrary connections between thoughts for complex dependency reasoning | Dependency analysis in Test phase |
| **ReAct** | Yao et al. | ICLR 2023 | Interleaving reasoning traces with tool actions grounds planning in reality | Per-phase THINK → ACT → OBSERVE → REFLECT loop |
| **Reflexion** | Shinn et al. | NeurIPS 2023 | Verbal self-critique after failures. **91% Pass@1 on HumanEval**. Rich reflections >> "try again" | Refine phase: diagnose → explain → prescribe protocol |

### Repository-Level Code Understanding

| Paper | Authors | Venue | Key Finding | SPECTRA Impact |
|-------|---------|-------|-------------|----------------|
| **RepoGraph** | Ouyang et al. | ICLR 2025 | Plug-in code graph module improves existing frameworks by **32.8% avg** across agent and procedural approaches | Convention-aware planning: modular, composable, non-invasive integration |
| **Code Retrieval in Coding Agents** | Jain | Preprints.org 2025 (pre-print) | Graph-based ranking (Aider) achieves 4.3–6.5% context utilization — high token efficiency; Cline's 3-tier retrieval provides complementary coverage | Structural analysis approach: lightweight, deterministic |

### Convention Files and Developer Context

| Paper | Authors | Venue | Key Finding | SPECTRA Impact |
|-------|---------|-------|-------------|----------------|
| **Beyond the Prompt: An Empirical Study of Cursor Rules** | Jiang & Nam | MSR 2026 | 401 repos analyzed; 5 categories: Convention, Guideline, Project, LLM Directive, Example | Taxonomy for convention file ingestion in retrofit protocol |

### Agent Architectures

| Paper | Authors | Venue | Key Finding | SPECTRA Impact |
|-------|---------|-------|-------------|----------------|
| **Plan-and-Execute Agents** | LangGraph | 2024 | Separate planner (high reasoning) from executor (fast, focused) | Model routing: reasoning-class for planning |
| **LLMCompiler** | LangGraph | 2024 | DAG of tasks for parallel execution, **3.6x speed improvement** | Execution plan with parallel phases |
| **Magentic-One** | Microsoft Research | 2024 | Multi-agent swarms with specialized roles | Agent routing: capability classes |

### Theoretical Foundations

| Work | Authors | Key Concept | SPECTRA Impact |
|------|---------|-------------|----------------|
| **Thinking, Fast and Slow** | Kahneman | Planning fallacy; premature commitment bias | Read-only constraint as pre-commitment device |
| **The Magical Number Seven** | Miller (1956) | Working memory: 7±2 chunks | 3–5 hypothesis range; phase output bounds |
| **Mathematical Theory of Communication** | Shannon (1948) | Information entropy | Plan entropy metric for adaptive verification |
| **Cognitive Load Theory** | Sweller (1988) | Cognitive load management in learning/problem-solving | Phase design; extended thinking budget |
| **Ulysses and the Sirens** | Elster (1979) | Pre-commitment devices in rational choice | Read-only planning as self-binding |

See [THEORY.md](THEORY.md) for formal treatment of how these foundations inform SPECTRA's design.

---

## Commercial Tool Analysis

### Cursor
- **Architecture:** Multi-model (~6 LLMs). Plan Mode generates `.cursor/plans/*.md`
- **Key finding:** Read-only enforcement via system reminder. Plans as actionable artifacts with todo dependencies
- **Source:** Reverse-engineered system prompts (sshh12, March 2025)

### Claude Code
- **Architecture:** Dynamic prompt assembly (40+ strings). Sub-agents. State machine toggle between read-only and full-access
- **Key finding:** Permission-first architecture. Plans at `.claude/plans/[name].md`
- **Source:** Piebald-AI/claude-code-system-prompts (98+ versions)

### GitHub Copilot
- **Architecture:** 3 agents (Agent, Plan, Ask). 5 planning tools in Visual Studio
- **Key finding:** GPT-5 + Claude Sonnet 4 showed ~15% better success rate with planning workflow on SWE-bench
- **Source:** Official documentation + internal testing reports

### Windsurf Cascade
- **Architecture:** Deep Graph Analysis. Persistent Memories across sessions
- **Key finding:** Memory-informed planning prevents repeated suggestion of rejected approaches

---

## Open-Source Implementations

| Tool | Planning Approach | Key Insight |
|------|-------------------|-------------|
| **Aider** | Architect Mode: reasoning model proposes, editor model implements | Two-model pipeline. o1 + DeepSeek = 85% benchmark |
| **Cline** | Plan/Act toggle. Different models per mode | DeepSeek R1 + Sonnet = 97% cost reduction |
| **Roo Code** | Multi-mode with Memory Bank | Per-mode tool restrictions + persistent memory |
| **LangGraph** | Plan-and-Execute graph with replanner | Replanner node decides: finish or new plan |
| **RA.Aid** | Three-stage CLI: Research → Planning → Implementation | Explicit per-stage model selection |

---

## Key Statistics

| Claim | Source | SPECTRA Relevance |
|-------|--------|-------------------|
| 25.4% Pass@1 improvement with planning | Jiang et al. (ASE 2024) | Validates plan-first |
| ~2x performance from plan diversity | Wang et al. (PlanSearch) | Validates Explore phase |
| 91% Pass@1 with Reflexion | Shinn et al. (NeurIPS 2023) | Validates Refine protocol |
| 50.8% SWE-bench at $0.34/issue | Xia et al. (Agentless) | Validates structured pipeline |
| 40%+ token waste from wrong assumptions | Commercial analysis | Validates CLARIFY phase |
| 97% cost reduction with model routing | Cline community | Validates model routing |
| 32.8% avg improvement with code graph | Ouyang et al. (RepoGraph, ICLR 2025) | Validates modular context enrichment |
| 5 convention categories in 401 repos | Jiang & Nam (MSR 2026) | Validates convention file taxonomy |
| 65% of devs report missing context in refactoring | Qodo (2025 State of AI Code Quality, industry survey, N=609) | Validates convention-aware planning |

---

*Last updated: 2026-03-01*
