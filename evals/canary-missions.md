# Canary Missions — SPECTRA

> v1.13.0 DSL-format missions for `eidolons canary spectra`. The legacy
> free-form catalog is preserved under "Legacy mission catalog (pre-DSL)"
> below for reference.

---

## Mission: smoke-default

### Prompt

Using the SPECTRA methodology, plan the following feature:

> Add a health-check endpoint to a REST API that returns service status and version.

Assume: Node.js / TypeScript, Express, no existing health check, no authentication required. The request is unambiguous; CLARIFY should be brief or skipped.

Walk through the cycle (CLARIFY → Scope → Pattern → Explore → Construct → Test → Refine → Assemble) and produce the final dual-format specification artefact (markdown body + YAML companion block). Do NOT write implementation code — specification only.

### Expected output shape

The response opens with a brief CLARIFY note (questions or "unambiguous → skipped"), then a Scope section with a complexity score (1-12) and request-type tag, then a Pattern section that names Express conventions, then Explore with at least two hypotheses, then Construct with the proposed shape, then a Test section with at least one GIVEN/WHEN/THEN story, then Assemble with the final dual-format artefact. The markdown body is followed by a YAML block companion. No JS / TS implementation code is present.

### Validation criteria

- MUST contain heading: `## Scope`
- MUST contain phrase: `complexity`
- MUST contain phrase: `GIVEN`
- MUST contain phrase: `WHEN`
- MUST contain phrase: `THEN`
- MUST contain phrase: `\`\`\`yaml`
- SHOULD contain phrase: `READ-ONLY`
- SHOULD contain phrase: `hypothes`
- SHOULD have token count between 1200 and 4000

---

## Mission: dual-format

### Prompt

Using SPECTRA, plan this change against an existing brownfield codebase:

> Extend the user authentication system to support multi-factor authentication via TOTP.

Assume: Ruby on Rails, Devise gem, PostgreSQL, existing RSpec suite, ~50k LOC.

Produce the dual-format SPECTRA artefact. The Test phase MUST include a YAML risk register listing at least one P0, P1, or P2 item. The Construct phase MUST tag identified risks with `P0`, `P1`, or `P2` markers.

### Expected output shape

A SPECTRA artefact whose final Assemble section contains both a markdown body and a YAML block. The markdown body has Scope, Pattern, Explore, Construct, Test, and Assemble sections. Explore lists at least three hypotheses with comparative scoring. Construct includes P0/P1/P2 risk tags. The YAML block contains at least: a Scope summary, a hypothesis array, and a risk register array with severity entries. No Ruby implementation code is present.

### Validation criteria

- MUST contain heading: `## Scope`
- MUST contain phrase: `P0|P1|P2`
- MUST contain phrase: `\`\`\`yaml`
- MUST contain phrase: `risk`
- MUST mention paths: `Gemfile`
- SHOULD contain phrase: `Devise`
- SHOULD contain phrase: `hypothes`
- SHOULD have token count between 1500 and 5000

---

## Mission: memory-round-trip

### Prompt

Using the SPECTRA methodology, plan the following feature:

> Add a rate-limiting middleware to a REST API to cap requests per IP to 100/min.

Assume: Node.js / TypeScript, Express, no existing rate limiting, Redis available.

Before starting CLARIFY, demonstrate the memory pre-flight: call
`mcp__crystalium__recall` with `scope={project: "test-project", agent_class_visibility: "spectra"}`,
`query="rate limiting middleware Node.js Express Redis"`, `k=5`, `layers=["semantic","episodic","procedural"]`.
After producing the final spec Markdown + YAML artefact (Assemble phase), emit the
ECL envelope skeleton (fill `from.eidolon: spectra`, `to.eidolon: apivr`,
`performative: PROPOSE`, `author_agent: spectra`) then call
`mcp__crystalium__ingest(envelope=<envelope>, payload=<spec markdown>)`.
Finally call `mcp__crystalium__session_end()`.

If `mcp__crystalium__*` tools are not available, proceed without them and note
"CRYSTALIUM absent — memory hooks skipped" at each would-be call site.

### Expected output shape

The response begins with a `mcp__crystalium__recall` call (or the graceful-skip
note). It then runs the full SPECTRA cycle and emits a dual-format spec artefact.
After Assemble, it shows a `mcp__crystalium__ingest` call (or graceful-skip note)
with `author_agent: spectra` in the provenance, followed by
`mcp__crystalium__session_end()` (or graceful-skip note).

### Validation criteria

- MUST contain phrase: `mcp__crystalium__recall` OR `CRYSTALIUM absent`
- MUST contain phrase: `mcp__crystalium__ingest` OR `CRYSTALIUM absent`
- MUST contain phrase: `mcp__crystalium__session_end` OR `CRYSTALIUM absent`
- MUST contain phrase: `author_agent` OR `CRYSTALIUM absent`
- MUST contain phrase: `spectra` (in provenance context)
- MUST contain phrase: `\`\`\`yaml`
- MUST contain phrase: `GIVEN`
- SHOULD contain phrase: `T1`
- SHOULD contain phrase: `graceful` OR `CRYSTALIUM absent`

---

## Mission: discovery-elicitation

### Prompt

Using the SPECTRA methodology, plan the following:

> We need better observability for our platform.

This request is **under-GOALED** — the objective itself is unspecified (no metric, no
scope, no named stakeholder, no platform definition). Before CLARIFY, run the DISCOVER
sub-mode: elicit stakeholders, the latent goal, success metrics, hard constraints, and
non-goals; emit `[GAP]` markers for each unknown; produce an elicitation summary and
hand it to CLARIFY. Do NOT jump straight to a Scope artifact or a plan. Do NOT write
implementation code.

### Expected output shape

The response opens with a `## DISCOVER` section that elicits stakeholders, latent
goal, success metrics, hard constraints, and non-goals, with `[GAP]` markers for the
unknowns and a coverage note. DISCOVER produces an elicitation summary (NOT a plan)
and explicitly hands off to CLARIFY. No Scope artifact, story hierarchy, or
implementation code appears before discovery completes.

### Validation criteria

- MUST contain phrase: `DISCOVER`
- MUST contain phrase: `[GAP]`
- MUST contain phrase: `stakeholder`
- MUST contain phrase: `CLARIFY`
- MUST contain phrase: `non-goal` OR `Non-goal` OR `out of scope`
- SHOULD contain phrase: `success metric` OR `baseline`
- SHOULD contain phrase: `latent` OR `elicit`
- SHOULD NOT contain heading: `## Construct`

---

## Mission: parallel-spec-trance

### Prompt

Using SPECTRA at **TRANCE tier** (assume the cortex has authorized TRANCE for this
high-stakes, high-complexity request), plan the following:

> Design the cross-service migration to split a monolithic order-processing service
> into independent inventory, payment, and fulfilment services with a new event bus.

Assume: complexity 10-12, multi-service STRATEGIC change, high rework risk. Because
TRANCE is authorized, run the **Parallel Spec Mode (G3 evaluator-optimizer)**: GENERATE
≥2 perspective-diverse candidate specs in clean-context branches, EVALUATE them with
the bias-hardened judge (note the mitigations applied), JUDGE-MERGE into one spec with
per-dimension `[DECISION]` provenance, and TERMINATE at the confidence gate or within
the 3-iteration cap. Do NOT write implementation code.

### Expected output shape

The response shows ≥2 perspective-diverse candidate specs (e.g. conservative,
pattern-leveraging, innovative), an EVALUATE step that explicitly notes the
LLM-as-judge bias mitigations (identity stripped / order rotated / length-normalized /
deterministic-anchor), a JUDGE-MERGE step that synthesizes ONE spec with per-dimension
`[DECISION]` provenance and a Rejected-Alternatives section, and a termination note at
the confidence gate or ≤3 iterations. The final output is a single dual-format spec.

### Validation criteria

- MUST contain phrase: `GENERATE` OR `candidate spec`
- MUST contain phrase: `[DECISION]`
- MUST contain phrase: `JUDGE-MERGE` OR `judge-merge`
- MUST contain phrase: `Rejected Alternatives` OR `rejected`
- MUST contain phrase: `bias` OR `identity` OR `rotate`
- MUST contain phrase: `\`\`\`yaml`
- SHOULD contain phrase: `TRANCE`
- SHOULD contain phrase: `cap 3` OR `3 iterations` OR `confidence`
- SHOULD contain phrase: `worktree` OR `read-only`

---

## Legacy mission catalog (pre-DSL)

> The original three free-form missions ("Simple Feature Spec", "Brownfield
> Analysis", "Ambiguous Request") are preserved below as historical reference.
> The v1.13.0 validator parses only the `## Mission: <id>` blocks above.

---

## Mission 1 — Simple Feature Spec (Greenfield)

**What it checks:** SPECTRA activates, runs CLARIFY, produces a dual-format artifact.

**Input prompt:**

```
Using SPECTRA, plan the following feature:
"Add a health check endpoint to a REST API that returns service status and version."

Assume: Node.js/TypeScript, Express framework, no existing health check, no authentication needed.
```

**Expected phase activations:**
CLARIFY (brief — intent is unambiguous), Scope (complexity 4–6, REQUEST type),
Pattern (Express routing patterns), Explore (2–3 hypotheses), Construct, Test, Assemble.

**Expected artifact shape:**
- CLARIFY: ≤2 clarifying questions, or skipped as unambiguous
- Scope score: 4–6/12
- ≥2 hypotheses in Explore
- Final artifact: Markdown spec + YAML block
- No implementation code in output

**Pass criteria:**
- [ ] Dual-format output produced (Markdown + YAML/JSON)
- [ ] No code written — specification only
- [ ] Story uses GIVEN/WHEN/THEN acceptance criteria
- [ ] Agent cites the READ-ONLY constraint at least once

---

## Mission 2 — Brownfield Analysis (Pattern Phase Emphasis)

**What it checks:** Pattern phase reads existing conventions, complexity routing triggers extended thinking.

**Input prompt:**

```
Using SPECTRA, plan the following change:
"Extend an existing user authentication system to support multi-factor authentication (MFA) via TOTP."

Assume: Ruby on Rails app, Devise gem for auth, PostgreSQL, existing RSpec test suite, ~50k LOC codebase.
```

**Expected phase activations:**
CLARIFY (asks about MFA recovery codes, enforcement policy), Scope (complexity 8–10,
CHANGE type, extended thinking triggered), Pattern (Devise patterns, auth migration risks),
Explore (3–5 hypotheses with 7-dim scoring), Construct, Test (adversarial layer),
Refine (likely 1 cycle), Assemble.

**Expected artifact shape:**
- CLARIFY: 2–3 questions about recovery flow, enforcement rollout, existing Devise config
- Scope complexity: ≥8/12 (triggers extended thinking notice)
- Pattern catalog: ≥2 existing auth conventions + risk flags
- ≥3 hypotheses in Explore with numeric scores
- Risk tags P0/P1/P2 present in Construct artifact

**Pass criteria:**
- [ ] CLARIFY asks ≥1 question about existing patterns before proceeding
- [ ] Scope score ≥7/12 with extended thinking noted
- [ ] Pattern catalog lists ≥2 existing conventions
- [ ] Dual-format output includes a YAML risk register

---

## Mission 3 — Ambiguous Request (CLARIFY Stress Test)

**What it checks:** SPECTRA does not begin planning when intent is underspecified.

**Input prompt:**

```
Using SPECTRA, plan: "Make the app faster."
```

**Expected behavior:**
CLARIFY phase activates fully. The agent does NOT proceed to Scope until
critical disambiguation questions are answered.

**Expected CLARIFY output:**
The agent asks ≤3 specific, numbered questions addressing at minimum:
1. Which part of the app is slow? (frontend, backend API, database queries, startup, etc.)
2. What does "faster" mean? (target metric, current baseline — e.g., p95 < 200ms)
3. What is the scope? (one endpoint, all endpoints, background jobs, initial load, etc.)

**Pass criteria:**
- [ ] Agent does NOT output a Scope artifact or plan before clarifying
- [ ] Exactly ≤3 clarifying questions (not more)
- [ ] Questions are numbered and specific (not vague)
- [ ] Agent explains why each question changes the plan's shape

---

*SPECTRA v4.2.0 — run these missions after `bash install.sh` or `bash tools/spectra-init.sh`*
