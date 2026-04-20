# SPECTRA — Canary Missions

Smoke tests to verify SPECTRA is installed and operating correctly.
Run one or more after installation.

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
