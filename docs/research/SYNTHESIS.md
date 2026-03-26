# Research Synthesis

How academic findings and commercial patterns map to SPECTRA v4 design decisions. Each decision traces to specific evidence.

---

## The Universal Pattern

> **Separate thinking from doing. Make the thinking verifiable. Make the results persistent.**

Every tool that outperforms a basic ReAct agent implements some version of this.

---

## Decision Map

### 1. CLARIFY — Ask Before You Plan
**Evidence:** Cursor enforces ≤2 questions. Claude Code uses `AskUserQuestion`. Copilot enters "Alignment" phase. Commercial analysis: 40%+ token waste from wrong assumptions.
**Decision:** ≤3 structured questions. Skip only when unambiguous.

### 2. Read-Only Planning
**Evidence:** Cursor: "YOU MUST NOT make any edits." Claude Code: "CRITICAL: READ-ONLY MODE." Copilot: Plan agent has no write tools.
**Decision:** No code, no edits during SPECTRA phases. Forces staying in problem space.

### 3. Plan Diversity (3–5 Hypotheses)
**Evidence:** PlanSearch nearly doubled Claude Sonnet's performance. ToT: 74% vs 4% on Game of 24. No commercial tool does this.
**Decision:** 3–5 distinct hypotheses with weighted rubric. Anti-strawman: if within 5%, re-observe.

### 4. 7-Dimension Weighted Rubric
**Evidence:** ToT uses "sure/maybe/impossible" — effective but crude. No commercial tool exposes scoring criteria.
**Decision:** 7 dimensions scored 1–10 with weights summing to 100%. Balances rigor with practicality.

### 5. 6-Layer Verification
**Evidence:** No commercial tool verifies plans before execution. Agentless validation phase achieves 50.8% SWE-bench.
**Decision:** Structural → Self-Consistency → Dependency → Constraint → Process Reward → Adversarial.
**Key insight:** 10x cheaper to catch a flawed plan than to execute one.

### 6. Reflexion-Style Refinement
**Evidence:** Reflexion: 91% Pass@1 on HumanEval. "Rich reflections >> 'try again'."
**Decision:** Diagnose → Explain → Prescribe → Apply → Re-verify. Max 3 cycles.

### 7. Plans as Persistent Artifacts
**Evidence:** Cursor stores `.cursor/plans/*.md`. Claude Code stores `.claude/plans/`. Copilot uses Markdown + JSON dual format.
**Decision:** Triple format: MD (human) + YAML (agent) + JSON (state). Files, not chat messages.

### 8. Adaptive Replanning
**Evidence:** ADaPT: attempt first, decompose on failure. LangGraph replanner node. No commercial tool does structured replanning.
**Decision:** Patch (minor) / Partial (moderate) / Full (major) based on failure scope.

### 9. Context Compaction
**Evidence:** "Context Rot" documented in Gemini analysis. Claude Code uses interleaved reasoning.
**Decision:** At 80% capacity, compress to Knowledge Artifact. Re-inject system prompt + artifact.

### 10. Vendor-Agnostic Model Routing
**Evidence:** Aider: o1 + DeepSeek = 85%. Cline: R1 + Sonnet = 97% cost reduction. Model leadership changes quarterly.
**Decision:** Capability classes (reasoning/speed) not vendor names.

### 11. Install Once, Plan Forever
**Evidence:** MSR '26 Cursor Rules study: 77.6% of repos encode conventions. Qodo 2025: 65% of developers report AI misses context during refactoring. RepoGraph (ICLR 2025): modular context enrichment improves frameworks by 32.8% avg without changing the framework itself.
**Decision:** Convention extraction is a one-time installation step (via `spectra-init.sh` + LLM), not a per-session cost. The output (`spectra-conventions.md`) is consumed as structural context through the existing CLARIFY and Pattern phases — no special retrofit logic in the core cycle. Convention maps improve Pattern Match quality within the existing scoring architecture (no arbitrary bonuses).

### 12. Brownfield Installation Depth
**Evidence:** ADaPT (Prasad et al.): attempt first, decompose on failure — don't over-analyze simple problems. EVPI framework (THEORY.md §3): gather information only when cost < expected rework savings.
**Decision:** Three installation depths for brownfield projects — Standard (init script + LLM), Deep (exemplar analysis + cross-validation), Structural (AST parsing + dependency graphs). Depth choice is made once at installation, not per session. Simple repos use Standard; large/complex repos benefit from Deep or Structural.

---

## Research Gaps

| Gap | SPECTRA's Choice | Confidence | Needs |
|-----|------------------|------------|-------|
| Optimal hypothesis count | 3–5 | Medium | Empirical testing |
| Rubric weight calibration | 25/20/15/15/10/10/5 | Medium | A/B testing |
| Self-consistency threshold | 70% overlap | Medium | Cross-project validation |
| Verification layer ordering | Current sequence | Low | Failure mode frequency data |
| Context compaction trigger | 80% capacity | Low | Model-dependent tuning |
| Convention file entropy reduction | Conventions lower plan entropy | Low | Empirical measurement across repos with/without conventions |
| Optimal convention depth | Progressive tiers mapped to complexity | Low | Case studies comparing Tier 1-only vs full convention analysis |

These gaps are where **community case studies** are most valuable.

For formal theoretical treatment of SPECTRA's design decisions — including EVPI analysis for confidence thresholds, Shannon entropy for adaptive verification, and cognitive load bounds for hypothesis generation — see [THEORY.md](THEORY.md).

---

*Last updated: 2026-03-01*
