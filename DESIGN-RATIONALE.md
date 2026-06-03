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

## DR-09 — ECL Emission Opt-In

**Decision:** SPECTRA emits an ECL v1.0 envelope alongside the spec when
`ECL_VERSION` is present in the install root. Emission is opt-in — absent
`ECL_VERSION`, no envelope is produced and non-ECL consumers experience zero
behaviour change.

**Why:** The `spectra → apivr` hand-off is the primary implementation-trigger
edge in the Eidolons pipeline. Without a structured envelope, the receiving
agent (APIVR-Δ) has no machine-readable provenance — it cannot verify that
the payload was not tampered with between planning and execution (Agent-in-the-Middle
class of attacks, ACL 2025). The ECL v1.0 sha256 integrity field (§6.2.2)
gates AiTM/prompt-infection at the message layer: APIVR-Δ can verify the hex
digest before acting on the spec. Opt-in posture preserves backwards
compatibility — installs without `ECL_VERSION` are fully functional, and the
ATLAS v1.5.0 precedent confirms this model works at scale across the Eidolons
roster.

**Evidence:** ECL v1.0 §status-of-this-document (opt-in for v1.0); ECL §6.2.2
(sha256 integrity gate); ACL 2025 Findings — Agent-in-the-Middle Attacks;
ATLAS v1.5.0 (PR #24 on Rynaro/ATLAS) as canonical adoption pattern; published
hand-off contract at `eidolons-ecl/contracts/spectra-to-apivr.yaml`.

---

## DR-10 — DISCOVER Phase: Open-Ended Elicitation Before Disambiguation

**Decision:** Add a pre-CLARIFY DISCOVER sub-mode that performs open-ended
requirements / stakeholder / goal elicitation when the GOAL itself is underspecified
(`IDEA` / `STRATEGIC` intent). DISCOVER produces a bounded, read-only elicitation
summary (stakeholders, latent goals, success metrics, hard constraints, non-goals)
with `[GAP]` markers for each unknown, then hands that summary to CLARIFY. It never
plans, never loops, and escalates to the human at low coverage.

**Why:** SPECTRA's only ambiguity-reduction surface today is CLARIFY, which
*disambiguates an already-known goal* via ≤3 plan-shape questions. It has no
open-ended discovery of latent goals, stakeholders, or success criteria. This is the
single biggest in-repo capability cap: specification / system-design is the dominant
multi-agent failure category, and multi-agent systems collapse toward ~30% accuracy
when latent stakeholder knowledge is never actively elicited. CLARIFY's ≤3-question
plan-shape contract is structurally incompatible with open-ended goal elicitation, so
folding discovery into CLARIFY would either skip discovery or overflow the 3-question
bound — hence a distinct, bounded pre-phase.

**Rejected alternative:** *Fold discovery into CLARIFY* — rejected because CLARIFY's
≤3-question plan-shape contract assumes the goal is known; open-ended goal elicitation
needs a different (unbounded-questions-but-single-pass) shape and a different trigger
(`IDEA`/`STRATEGIC` vs `REQUEST`/`CHANGE`).

**Evidence:** R3-01 (MAST — ~43.8% system-design / specification failures, the
dominant MAS failure category); R3-11 (HiddenBench — elicitation failure: MAS
collapse to ~30% when latent knowledge is not actively elicited); D2 (SPECTRA plans,
never implements — DISCOVER stays read-only); D5 (bounded — elicitation summary +
`[GAP]` escalation, no unbounded interview loop); D7 (`[GAP]` markers per unknown).

**Scope note:** True interactive multi-turn stakeholder interviewing requires an
interactive runtime the nexus does not provide; the in-repo deliverable is the
elicitation METHODOLOGY + structured summary artifact a human or host conversation
drives, not a live elicitation agent.

---

## DR-11 — Parallel Evaluator-Optimizer Spec Mode with Bias-Hardened Judge

**Decision:** Operationalize the named-but-unimplemented G3 TRANCE form as a bounded,
read-only parallel mode that WRAPS the standard S→P→E→C→T→R→A cycle:
GENERATE (2-4 perspective-diverse clean-context candidate specs, default 3, cap 4) →
EVALUATE (7-dimension rubric with explicit judge-bias mitigation: authoring-identity
strip, presentation-order rotation, length normalization, deterministic-check anchor) →
JUDGE-MERGE (one synthesized spec, per-dimension `[DECISION]` provenance, rejected
rationale carried forward) → TERMINATE (confidence ≥85% OR hard cap 3 iterations, else
`[GAP]` escalation). TRANCE-gated; never the default.

**Why:** The G3 evaluator-optimizer form is named in the nexus trance-matrix but had
zero operationalization in the repo — the Explore phase generates hypotheses
sequentially in a single context and Refine is a single-context Reflexion loop, so
there was no parallel candidate-spec generation, no clean-context fan-out, and no
defined judge-merge or evaluator-bias mitigation. The evaluator step is exactly the
LLM-as-judge surface that inherits position / verbosity / self-preference bias, so it
must be bias-hardened, not assumed neutral.

**Rejected alternatives:**
- *Naive N-identical sampling* — rejected: quality dominates diversity-for-its-own-sake,
  so cap at 3-4 high-quality perspective-diverse branches rather than maximize N (R3-06).
- *Unbounded multi-agent debate* — rejected: debate needs deliberate tuning and a hard
  termination bound, not free-running iteration (R3-04, D5).
- *In-context sequential generation* — rejected: branches sharing one context
  self-condition on each other's trajectory; clean-context subagents are required to
  preserve genuine diversity (R1-03).

**Evidence:** R3-04 (deliberate perspective-diversity, not naive MAD); R3-06 (quality
dominates diversity — cap branches); R3-09 (LLM-as-judge position / verbosity /
self-preference bias → identity-strip + order-rotate + length-normalize +
deterministic-anchor); R1-03 (clean-context subagents prevent self-conditioning);
R1-01 (read-only ⇒ safe parallel, no worktree isolation); cost-ceiling C1 (≤5 branches,
capped 4); D5 + trance-matrix R4 (hard cap 3 iterations + explicit escalation).

**Scope note:** The bias mitigations and branch/iteration caps are interpreted by the
host LLM, not mechanically enforced — mechanical orchestration enforcement is a
nexus-level concern outside this repo. The in-repo win is making the mitigations
EXPLICIT and auditable in the spec output.

---

*SPECTRA v4.3.0 — CC BY-SA 4.0*
