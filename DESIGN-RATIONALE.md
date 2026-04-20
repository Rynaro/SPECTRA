# SPECTRA — Design Rationale

Maps key architectural decisions to research evidence. For the full evidence base,
see [`docs/research/SYNTHESIS.md`](docs/research/SYNTHESIS.md) and
[`docs/research/THEORY.md`](docs/research/THEORY.md).

---

## DR-01 — Plan/Execute Separation

**Decision:** SPECTRA operates in READ-ONLY mode during all planning phases.
Code writing is a separate phase by a different agent.

**Why:** All major commercial AI coding tools — Cursor, Claude Code, GitHub Copilot —
independently converged on this architecture. Mixing planning and execution forces
early commitment before the solution space is understood, and contaminates planning
context with implementation detail that biases hypothesis generation.

**Evidence:** Universal convergence in commercial tools (competitive analysis, 2024);
ADaPT-style efficiency arguments; Cognitive Load Theory (Sweller — splitting planning
and execution reduces intrinsic load in each phase independently).

---

## DR-02 — Structured Clarification Before Decomposition

**Decision:** CLARIFY is a mandatory phase that runs before Scope. It asks ≤3
numbered questions targeting only decisions that change the plan's shape.

**Why:** Ambiguous requirements account for 40%+ of wasted planning effort in
commercial tool analysis. Asking more than 3 questions degrades user experience
without proportional benefit. Each question must be justified by "this changes the plan."

**Evidence:** Commercial tool analysis (Claude Code, Cursor clarification UX, 2024);
≤3 constraint from user research patterns; WHO/WHAT/WHY/CONSTRAINTS parse framework.

---

## DR-03 — 3–5 Hypotheses in Explore

**Decision:** The Explore phase generates 3–5 candidate approaches, not 1.

**Why:** Plan diversity dominates code diversity in performance impact.
Miller's Law bounds working memory at 7±2 items; 3–5 hypotheses fits within
reviewable cognitive load while ensuring meaningful diversity. Fewer than 3
collapses to single-path planning; more than 5 exceeds reviewable scope without
significant diversity gain.

**Evidence:** PlanSearch (Wang et al., 2024) — plan-level diversity nearly doubles
performance vs. code-level diversity; Miller's Law (1956); Tree of Thoughts value
assessment methodology (Yao et al., 2023).

---

## DR-04 — 7-Dimension Weighted Scoring Rubric

**Decision:** Hypotheses are evaluated on 7 dimensions (correctness, completeness,
feasibility, risk, maintainability, performance, alignment) with explicit weights,
producing a normalized score.

**Why:** Structured evaluation beats intuition for complex trade-off decisions.
The 7 dimensions cover the principal failure modes observed in commercial planning
tools. Weighted scores enable automated hypothesis ranking and support the Assemble
phase's confidence gate.

**Evidence:** Extends Tree of Thoughts value assessment (Yao et al., 2023);
dimensions derived from post-mortem analysis of planning failures.
Full rubric in `docs/spectra-methodology/scoring.md`.

---

## DR-05 — 6-Layer Verification

**Decision:** The Test phase runs 6 verification layers: structural, logical,
adversarial, integration, edge-case, and stakeholder.

**Why:** Catching a flaw in the plan is 10× cheaper than catching it after execution.
Six layers cover distinct failure modes; fewer layers leave systematic gaps.
The adversarial layer (deliberately trying to break the plan) catches assumptions
that structural checks miss.

**Evidence:** Shift-left testing economics; failure taxonomy analysis (8 plan failure
modes, documented in `docs/research/THEORY.md`); commercial tool verification
pattern analysis.

---

## DR-06 — Reflexion-Style Refinement (Max 3 Cycles)

**Decision:** The Refine phase uses a structured Diagnose → Explain → Prescribe
loop, capped at 3 cycles.

**Why:** Shinn et al. (Reflexion, NeurIPS 2023) showed structured self-critique
achieves 91% Pass@1 on HumanEval. Generic "improve this" produces superficial
changes; targeted diagnosis produces substantive revision. The 3-cycle cap prevents
oscillation; the Δ < 0.3 stop criterion from `docs/research/THEORY.md` catches
diminishing returns before the cap is reached.

**Evidence:** Reflexion (Shinn et al., NeurIPS 2023); diminishing returns
formalization in `docs/research/THEORY.md`; oscillation detection pattern.

---

## DR-07 — Dual-Format Artifact Persistence

**Decision:** All SPECTRA artifacts are produced simultaneously in human-readable
Markdown and agent-executable YAML/JSON.

**Why:** Plans must survive context-window boundaries. Markdown serves human
reviewers and maintains narrative coherence. YAML/JSON enables downstream agents
to parse structured fields (scope, hypotheses, acceptance criteria) without
natural-language parsing. The dual format also enables state machine–style
plan tracking across sessions.

**Evidence:** ADaPT adaptive replanning architecture (Prasad et al.);
context persistence requirements from multi-session agent analysis;
State Machine JSON template in `docs/spectra-methodology/templates.md`.

---

## DR-08 — Complexity 4–12 Routing

**Decision:** SPECTRA uses a 4-dimension complexity matrix producing scores from
4 to 12. Thresholds: 4–6 = standard; 7–9 = extended thinking (2× token budget);
10–12 = human-in-the-loop.

**Why:** Single-threshold routing (complex/simple) is too coarse. A continuous
12-point scale with two routing thresholds allows proportional resource allocation.
The 7+ extended-thinking threshold aligns with observed commercial tool behavior
for "complex" task classification.

**Evidence:** Complexity matrix derived from multi-dimensional task analysis;
thresholds calibrated from commercial tool analysis.
Full scoring protocol in `docs/spectra-methodology/scoring.md`.

---

*SPECTRA v4.2.0 — CC BY-SA 4.0*
