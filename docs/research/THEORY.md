# Theoretical Foundations of SPECTRA

Deeper treatment of the decision-theoretic, information-theoretic, and cognitive science principles underlying SPECTRA's architecture. This document is for researchers, methodology evaluators, and contributors who want to understand *why* SPECTRA's design decisions are optimal, not just *what* they are.

For practitioners: you don't need this file. The core [SPEC.md](../spectra-methodology/SPEC.md) is self-contained.

---

## 1. Plan-Execute Separation as Decision Hygiene

SPECTRA's read-only planning constraint isn't an arbitrary rule — it implements a principle from decision theory: **separate information-gathering from commitment**.

In behavioral economics, Kahneman (2011) identifies the "planning fallacy" as a cognitive bias where agents underestimate time, cost, and risk *because they begin execution before fully understanding the problem space*. The act of coding creates sunk-cost anchoring that distorts subsequent planning.

SPECTRA's read-only constraint is a **pre-commitment device** (Elster, 1979). By making mutations physically unavailable during planning, we eliminate the class of errors caused by premature commitment. This parallels the architectural decision in every commercial tool (Cursor, Claude Code, Copilot) to restrict write-tools during plan mode — a convergent evolution driven by the same underlying decision theory.

**Formal framing:** Let $P(success | plan\_then\_act)$ and $P(success | interleaved)$ represent success probabilities. Self-Planning Code Generation (Jiang et al., ASE 2024) measured a 25.4% relative improvement, suggesting:

$$P(success | plan\_then\_act) \approx 1.25 \times P(success | interleaved)$$

This is the empirical basis for SPECTRA's most fundamental constraint.

---

## 2. Plan Diversity and Information Theory

### Why 3–5 Hypotheses?

SPECTRA requires 3–5 genuinely distinct hypotheses in the Explore phase. This specific range is grounded in two intersecting findings:

**Miller's Law (1956):** Human working memory can hold 7±2 chunks. Since each hypothesis requires evaluation across 7 scoring dimensions, the cognitive overhead per hypothesis is ~7 chunks. At 3 hypotheses, total load ≈ 21 chunks (manageable with structured output). At 5, total load ≈ 35 chunks (approaching limits even with external memory). Beyond 5, quality degrades as the evaluator loses coherence.

**PlanSearch (Wang et al., 2024):** Diversity at the plan level produces nearly 2× the performance of diversity at the code level. The critical insight is that plans occupy a *different information space* than code — two plans can be structurally distinct even when their eventual code implementations overlap. Searching this space is higher-leverage than searching the code space.

**Information-theoretic optimum:** The value of an additional hypothesis follows a log-diminishing curve:

$$V(n) \approx V_0 \cdot \log_2(n+1) - C \cdot n$$

Where $V_0$ is the value of the first hypothesis and $C$ is the cognitive cost per hypothesis. This curve peaks between 3 and 5 for typical engineering tasks, which is exactly SPECTRA's prescribed range.

### The Anti-Strawman Rule

SPECTRA requires that if all hypotheses score within 5% of each other, the agent must re-observe. This prevents a degenerate case where the Explore phase generates token-expensive but informationally redundant hypotheses — "three different ways of saying the same thing."

From an information-theoretic perspective, the 5% threshold detects low **inter-hypothesis entropy**. If $H(hypotheses) < \epsilon$, the observation space was too narrow. Re-observation from different angles (performance vs. simplicity vs. extensibility) increases entropy, producing genuinely distinct strategies.

---

## 3. Confidence Gating as Expected Value of Information

### Beyond Threshold Heuristics

SPECTRA's confidence gating (≥85% auto-proceed, 70–84% validate, 50–69% collaborate, <50% escalate) appears to be a simple threshold system. The deeper justification is the **Expected Value of Perfect Information (EVPI)** framework.

For any plan at confidence $c$:
- **Expected cost of proceeding:** $(1-c) \times R$ where $R$ is the rework cost if the plan is wrong
- **Expected cost of gathering more information:** $I$ (tokens, time, human attention)

The optimal strategy is to proceed when:

$$I > (1-c) \times R$$

That is: gather more information only when the cost of gathering is less than the expected rework savings.

**SPECTRA's thresholds approximate this calculus:**

| Confidence | Expected rework | Information cost | Decision |
|------------|----------------|------------------|----------|
| ≥85% | Low ($R \times 0.15$) | Any $I$ is wasteful | AUTO_PROCEED |
| 70–84% | Moderate | Human review ($I$ is cheap) | VALIDATE |
| 50–69% | High | Targeted questions ($I$ is moderate) | COLLABORATE |
| <50% | Very high | Full re-scope ($I$ is large but justified) | ESCALATE |

**Calibration note:** The 85% threshold is deliberately conservative. In mission-critical systems, raise it to 90%. In rapid prototyping, lower it to 80%. The principle (EVPI comparison) remains constant; the parameter is domain-tuned.

---

## 4. Plan Entropy: An Adaptive Verification Budget

### The Problem with Fixed Verification

SPECTRA's 6-layer verification is comprehensive, but applying all 6 layers to a simple ≤2d story is wasteful, while applying only 6 layers to a 10/12 complexity strategic plan may be insufficient. We need an **adaptive verification budget**.

### Plan Entropy Metric

Define **plan entropy** as the Shannon entropy of the plan's decision space:

$$H(plan) = -\sum_{i=1}^{n} p_i \log_2 p_i$$

Where $p_i$ represents the probability that decision $i$ in the plan could go differently (i.e., an alternative exists that a competent engineer might choose).

**Intuition:**
- A plan with one obvious approach per decision has low entropy (few alternatives = high certainty).
- A plan where every decision has 3 equally viable alternatives has high entropy (many alternatives = high uncertainty).

**Verification budget allocation:**

| Plan Entropy | Complexity | Verification Depth |
|-------------|------------|-------------------|
| Low ($H < 1.0$) | 4–6 | Structural + Constraint only (2 layers) |
| Medium ($1.0 ≤ H < 2.0$) | 7–9 | Full 6-layer verification |
| High ($H ≥ 2.0$) | 10–12 | Full 6-layer + adversarial red-team + human review |

**Practical approximation:** Exact entropy calculation requires enumerating alternative decisions, which is expensive. A useful proxy: count the number of decisions in the plan where the Explore phase produced hypotheses within 15% of the winner. Each such decision contributes ~1 bit of entropy.

---

## 5. Cognitive Load Theory and Phase Design

### Working Memory Budget Model

Each SPECTRA phase is designed to produce a bounded set of outputs that feed the next phase. This isn't coincidental — it implements **Cognitive Load Theory** (Sweller, 1988).

LLMs, despite massive context windows, exhibit performance degradation when reasoning over too many concurrent elements — analogous to human working memory limits. The practical limit for structured reasoning is approximately 7 independent elements (Miller, 1956), which maps to SPECTRA's design:

| Phase | Key Outputs | Count | Within 7±2? |
|-------|-------------|-------|-------------|
| CLARIFY | WHO, WHAT, WHY, CONSTRAINTS, gaps, questions | 6 | ✓ |
| Scope | Intent type, complexity, boundaries (3 cols), assumptions | 6 | ✓ |
| Pattern | Match candidates (5), strategy decision, adaptations | 7 | ✓ |
| Explore | Hypotheses (3–5), scores, selection, rationale | 6–8 | ✓ |
| Construct | Stories (variable, but each is independent) | ≤7 per feature | ✓ |
| Test | 6 verification layers | 6 | ✓ |
| Refine | 5 critique dimensions | 5 | ✓ |

When a phase's output exceeds ~7 elements, it's a signal to decompose further (which is exactly what the >8d rule enforces for stories).

### Implication for Extended Thinking

SPECTRA's "complexity ≥7 → extended thinking (2x tokens)" rule is a cognitive load management strategy. Higher complexity means more concurrent elements to reason about, requiring more working memory (tokens) to maintain coherence. The 2x multiplier is a pragmatic approximation; the theoretically optimal multiplier is:

$$budget = base \times (1 + \frac{complexity - 4}{8})$$

This scales from 1× at complexity 4 to 2× at complexity 12, with linear interpolation.

---

## 6. Failure Taxonomy for Plan Diagnostics

Not all plan failures are equal. A formal taxonomy enables targeted remediation rather than generic "refine harder."

### Taxonomy

| Failure Mode | Definition | Diagnostic Signal | SPECTRA Remedy |
|-------------|-----------|-------------------|----------------|
| **Under-specification** | Plan lacks detail for unambiguous execution | Agent asks clarifying questions during execution | Add acceptance criteria; return to Construct |
| **Over-specification** | Plan constrains implementation unnecessarily | Multiple valid implementations blocked by overly rigid plan | ADaPT: collapse steps; loosen constraints |
| **Dependency Blindness** | Missing call-site or import-chain impacts | Broken build after executing "complete" plan | Strengthen Dependency layer in Test; add structural context gathering |
| **Assumption Drift** | Initial assumptions became invalid mid-plan | Steps invalidated by earlier discoveries | Full replan from Scope with new constraints |
| **Scope Creep** | Plan expanded beyond original boundaries | Token budget exhausted; tangential stories appear | Enforce boundary table from Scope; drop out-of-scope stories |
| **Premature Optimization** | Plan optimizes before correctness established | Complex architecture for simple problem | Check complexity score; apply ADaPT rule (≤5 → simplify) |
| **Stale Context** | Plan based on outdated codebase state | File contents changed since planning began | Refresh structural context; re-run Dependency check |
| **Oscillating Refinement** | Refine cycle changes A→B→A→B | Score doesn't improve across cycles | Detect: if dimension score returns to prior value, escalate |

### Usage in Verification

During the Test phase's Adversarial layer, check the plan against each failure mode:

> "Which failure modes from the taxonomy could apply to this plan? For each applicable mode, what is the diagnostic signal, and is the remedy already in place?"

This transforms adversarial review from open-ended "what could go wrong?" into structured diagnostic checklist.

---

## 7. Diminishing Returns in Refinement

### The Problem

SPECTRA allows up to 3 refinement cycles. But when should we stop at 1? When should we use all 3? Without a formal criterion, agents either under-refine (stopping too early) or waste tokens on polish that doesn't improve outcomes.

### Criterion

Define **marginal improvement** as the change in aggregate critique score between cycles:

$$\Delta_n = S_n - S_{n-1}$$

Where $S_n$ is the mean of all 5 critique dimension scores at cycle $n$.

**Stop when:** $\Delta_n < 0.3$ (on the 1–5 scale)

This means: if a full refinement cycle improved the average score by less than 0.3 points, further cycles are unlikely to yield meaningful improvement. The 0.3 threshold corresponds to approximately one sub-level improvement on one dimension — below the threshold of "worth another pass."

**Emergency stop:** If any dimension *decreases* between cycles (oscillation), halt immediately and escalate. This is the "Oscillating Refinement" failure mode from the taxonomy above.

---

## 8. Scoring Calibration Protocol

### The Problem

SPECTRA's 7-dimension rubric (scoring.md) produces numerical scores, but without calibration, different evaluators (human or LLM) will score the same plan differently. This undermines both the Explore phase (hypothesis selection) and the Assemble phase (confidence calculation).

### Anchoring Protocol

Before using the rubric in a new context, calibrate with three reference plans:

| Reference | Quality | Expected Score Range |
|-----------|---------|---------------------|
| **Anchor-Low** | Plan with obvious gaps (missing acceptance criteria, vague stories, no dependency analysis) | 25–40 weighted total |
| **Anchor-Mid** | Competent plan with minor issues (one ambiguous criterion, coverage not specified) | 60–75 weighted total |
| **Anchor-High** | Exemplary plan (all criteria clear, edge cases addressed, clean dependency chain) | 85–95 weighted total |

**Protocol:**
1. Score all three anchors using the rubric.
2. Compare your scores to the expected ranges.
3. If your scores diverge by >10 points from expected ranges, recalibrate your interpretation of the dimension descriptors.
4. For LLM-as-Judge, include all three anchors with pre-assigned scores in the prompt as few-shot examples.

**Inter-rater target:** Krippendorff's α ≥ 0.67 (acceptable agreement) across evaluators after calibration.

The `examples/` directory contains plans at each quality level that can serve as calibration anchors.

---

## 9. Bayesian Updating in Pattern Phase

### Current Approach

The Pattern phase uses static thresholds: ≥85% similarity → USE_TEMPLATE, 60–84% → ADAPT, <60% → GENERATE.

### Enhanced Approach

A Bayesian formulation improves this by incorporating prior success rates:

$$P(success | pattern, evidence) = \frac{P(evidence | success, pattern) \times P(success | pattern)}{P(evidence)}$$

Where:
- $P(success | pattern)$ is the historical success rate of this pattern (from episodic memory)
- $P(evidence | success, pattern)$ is the likelihood that the current problem matches the pattern's success conditions

**Practical implementation:** When episodic memory contains prior outcomes for a pattern (e.g., "BallotImportFlow succeeded 3/4 times, failed on file >100MB"), adjust the strategy threshold:

- Pattern with 100% success history: lower threshold by 5% (trust it more)
- Pattern with <75% success history: raise threshold by 10% (trust it less)
- Pattern with known failure conditions matching current context: skip regardless of similarity

This is a lightweight Bayesian update that doesn't require mathematical infrastructure — just conditional threshold adjustment based on memory.

---

## 10. Convention Files as Entropy Reduction

### The Observation

Convention files — `.cursorrules`, `CLAUDE.md`, `AGENTS.md`, `ARCHITECTURE.md`, ADRs — are a growing pattern across AI-assisted development. An empirical study of 401 repositories with cursor rules (Jiang & Nam, MSR 2026) identified 5 categories that developers encode: Convention, Guideline, Project Information, LLM Directive, and Example.

From SPECTRA's perspective, these files are **entropy-reducing inputs** that directly benefit the planning cycle.

### Formal Framing

Recall from Section 4 that plan entropy measures the uncertainty in the plan's decision space:

$$H(plan) = -\sum_{i=1}^{n} p_i \log_2 p_i$$

Each convention file constrains decisions by eliminating alternatives. If a convention specifies "business logic goes in Service Objects at `app/services/`," then the decision "where to place business logic" has $p = 1$ for one option, contributing 0 bits of entropy. Without the convention, an agent might consider 3–4 equally viable locations, contributing ~2 bits.

**Effect:** Convention files reduce plan entropy by collapsing multi-option decisions into single-option decisions. The aggregate reduction depends on how many planning decisions the conventions cover.

### Implications for Verification

From the adaptive verification budget (Section 4): lower entropy → fewer verification layers needed. A codebase with comprehensive convention files shifts the verification budget downward:

| Without Conventions | With Conventions | Reason |
|---|---|---|
| Medium entropy → full 6-layer | Low entropy → 2 layers | Conventions eliminated decision alternatives |
| More hypotheses needed in Explore | Fewer distinct hypotheses viable | Convention constraints reduce hypothesis space |
| Higher cognitive load in Construct | Lower cognitive load | Naming, paths, and patterns are pre-decided |

### Installation Depth as EVPI Application

Not all repositories have convention files. Not all convention files are comprehensive. The EVPI framework (Section 3) determines how much analysis to invest during SPECTRA installation:

| Installation Depth | Analysis | One-Time Cost | When Worthwhile |
|---|---|---|---|
| **Standard** | `spectra-init.sh` + LLM adaptation prompt | Minutes | Most projects |
| **Deep** | Exemplar selection + LLM convention extraction + cross-validation | Hours | Large codebases (>500 files), no existing conventions |
| **Structural** | AST parsing + dependency graphs + importance ranking | Hours | Monorepos, microservices, non-obvious architecture |

The key insight: this analysis cost is paid **once at installation**, not per SPECTRA session. After installation, the convention map is consumed as structural context through the existing CLARIFY and Pattern phases with near-zero marginal cost. This makes even the Deep and Structural tiers cost-effective — they amortize over every subsequent planning session.

See [RETROFIT.md](RETROFIT.md) for the brownfield installation protocol.

---

## 11. Connections to Formal Methods

### Future Direction: Plan Verification via Lightweight Formal Methods

Currently, SPECTRA's 6-layer verification is heuristic — it checks structural properties and consistency, but doesn't mathematically prove plan correctness. For high-criticality systems, lightweight formal methods could strengthen verification:

- **Dependency verification via topological sort:** The plan's story dependency graph must be a DAG. Any cycle indicates a structural error. This is trivially checkable.
- **Timebox arithmetic:** The sum of story timeboxes within a feature must be ≤ the feature's timebox. This is a simple constraint satisfaction check.
- **State machine validation:** The `.state.json` format defines a state machine. We can verify that all states are reachable, no deadlocks exist, and every step has a defined successor.

These lightweight checks are feasible today and could be automated in the `spectra-init.sh` tooling or as a CI check for plan artifacts.

---

## References

- Elster, J. (1979). *Ulysses and the Sirens*. Cambridge University Press.
- Kahneman, D. (2011). *Thinking, Fast and Slow*. Farrar, Straus and Giroux.
- Miller, G.A. (1956). "The magical number seven, plus or minus two." *Psychological Review*, 63(2), 81–97.
- Shannon, C.E. (1948). "A mathematical theory of communication." *Bell System Technical Journal*, 27(3), 379–423.
- Sweller, J. (1988). "Cognitive load during problem solving." *Cognitive Science*, 12(2), 257–285.

For SPECTRA-specific research foundations (planning papers, commercial tool analysis, open-source patterns), see [REFERENCES.md](../research/REFERENCES.md).

---

*SPECTRA — Theoretical Foundations*
