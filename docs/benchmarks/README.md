# SPECTRA Benchmarks

> **🚧 Status: Benchmarks In Progress**
>
> The evaluation framework has been designed and peer-reviewed for methodological rigor. Data collection is underway. Initial results will be published here as they become available.
>
> **Want to contribute data?** See [case study submission template](../.github/ISSUE_TEMPLATE/case_study_submission.md).

---

## Why Benchmarks Are Hard for Planning Methodologies

Existing benchmarks (SWE-bench, HumanEval, MBPP) evaluate **code generation** — the builder, not the architect. They measure whether generated code passes tests, not whether the *plan* that preceded it was sound.

SPECTRA evaluates **plan quality**. There is no existing benchmark for this. We designed one from scratch.

## Evaluation Architecture

Our benchmark uses a **3-layer evaluation** with cross-cutting model portability testing:

### Layer 1: Plan Quality (Intrinsic)

Does the methodology produce good specifications?

**7 evaluation dimensions** (weighted): Completeness (20%), Correctness (20%), Unambiguity (15%), Consistency (15%), Testability (10%), Decomposition Quality (10%), Dependency Accuracy (10%).

**Triple assessment:**
- Human expert review (2-3 engineers, blind evaluation, targeting Krippendorff's α ≥0.67)
- LLM-as-Judge jury (3 model families, G-Eval style CoT, majority voting)
- Structural automated checks (10 deterministic pass/fail criteria)

**Cross-validation:** Human↔Judge correlation target r ≥0.75 to validate scalable evaluation.

### Layer 2: Plan→Execution (Extrinsic)

Do SPECTRA plans lead to better execution outcomes?

**A/B/C comparison:** SPECTRA vs Direct Generation vs Basic CoT planning, with identical execution agents across all conditions. Only the planning methodology varies.

**Metrics:** Resolve rate, first-attempt success rate, replan frequency, regression rate, token consumption, wall-clock time.

### Layer 3: Efficiency

Is the upfront planning cost justified?

**Hypotheses (pre-registered):**
- H1: Total cost (planning + execution) with SPECTRA ≤ Direct for complexity ≥7/12
- H2: First-attempt success rate higher with SPECTRA (p<0.05)
- H3: Replan rate lower with SPECTRA (p<0.05)

**Statistical rigor:** N≥30 per condition, paired t-test/Wilcoxon, Cohen's d effect sizes, α=0.05 with Bonferroni correction.

### Cross-Cutting: Model Portability

Does SPECTRA work across LLM families?

**Requirement:** ≥3 model families (e.g., Claude, GPT, Gemini or open-weight).
**Target:** Cross-model plan quality variance σ < 0.5 on 5-point scale. Structural compliance ≥90% for all models.

---

## Task Corpus

**Minimum viable:** 30 tasks (10 per complexity band: 4-6, 7-9, 10-12).
**Target:** 100 tasks across 5+ repositories, 3+ languages, 3 task types (bug fix, new feature, refactor).

Tasks sourced from real GitHub issues with known resolutions, enabling ground-truth comparison.

---

## Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| Instrument development (rubric, judge prompts, checker) | 2 weeks | ✅ Complete |
| Task corpus construction | 2 weeks | 🔄 In progress |
| Data collection (3 conditions × full corpus) | 4 weeks | ⏳ Pending |
| Analysis and publication | 2 weeks | ⏳ Pending |

---

## Minimum Viable Benchmark (Fast Track)

For those wanting quick results before the full benchmark:

| Aspect | Fast Track | Full Benchmark |
|--------|-----------|----------------|
| Tasks | 10 (complexity 7+) | 30-100 |
| Conditions | 2 (SPECTRA vs Direct) | 3 (+ Basic CoT) |
| Evaluation | Structural checks + resolve rate | Triple assessment |
| Models | 1 family | 3+ families |
| Duration | ~1 week | ~10 weeks |
| Publishable? | Blog post / initial data | Peer-reviewable |

---

## Contributing Benchmark Data

The most valuable contribution is **real-world case study data**. Each case study becomes a data point in our benchmark.

**What makes good data:**
- Real engineering tasks (not synthetic)
- Measurable outcomes (confidence scores, replan frequency, acceptance criteria pass rates)
- Honest reporting including failures
- Before/after comparison if possible (task done with and without SPECTRA)

See the [case study template](../.github/ISSUE_TEMPLATE/case_study_submission.md).

---

## Detailed Methodology

For the complete evaluation framework design, scoring rubrics, and statistical methodology, see:
- `methodology.md` — Full benchmark design (when published)
- `rubric.md` — 7-dimension × 5-level scoring rubric (when published)

---

*SPECTRA v4.2.0 — Benchmarks*
