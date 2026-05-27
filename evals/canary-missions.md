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
