---
artifact: acceptance-criteria
version: 4.11.0
---

# Acceptance Criteria — EARS Form Template (optional, additive)

This template is the OPTIONAL, additive structured form for `acceptance_checks[]`
items, as ratified by ESL 1.1 §2.5 (Easy Approach to Requirements Syntax). It is
polish on top of SPECTRA's existing `GIVEN [context] WHEN [action] THEN [outcome]`
checklist style (`docs/spectra-methodology/catalog.md` — Story Format), not a
replacement for it: the plain-string and minimal `{id, verify_method}` acceptance-
check forms remain 100% valid and produce **no** finding from ESL's advisory C7
lint. Use this template when a consumer project has adopted ESL
(`skills/esl-hop/SKILL.md`) and a spec's stories benefit from a mechanically checkable,
closed grammar.

## The closed EARS grammar (five fixed sentence forms)

Every acceptance criterion is exactly ONE of the five canonical EARS sentence
forms below. Each form maps onto the `{id, given, when, then, verify_method}`
shape ESL 1.1 §2.5 carries on `change.json`'s `acceptance_checks[]` — `given` is
SPECTRA's Gherkin-style precondition slot, `when` is the EARS trigger/guard,
`then` is the EARS "THE SYSTEM SHALL …" response. An item is "in the EARS form"
iff it declares at least one of `given` / `when` / `then`.

| # | Form | Sentence pattern | `given` | `when` | `then` |
|---|------|-------------------|---------|--------|--------|
| 1 | **Ubiquitous** | THE SYSTEM SHALL \<response\> | — | — | \<response\> (always true, no trigger/state) |
| 2 | **Event-driven** | WHEN \<trigger\> THE SYSTEM SHALL \<response\> | optional extra precondition | \<trigger\> | \<response\> |
| 3 | **State-driven** | WHILE \<state\> THE SYSTEM SHALL \<response\> | \<state\> | — | \<response\> |
| 4 | **Unwanted behavior** | IF \<trigger\> THEN THE SYSTEM SHALL \<response\> | optional extra precondition | IF \<trigger\> (guard/error condition) | \<response\>, phrased as the safe fallback |
| 5 | **Optional feature** | WHERE \<feature is included\> THE SYSTEM SHALL \<response\> | \<feature enabled/present\> | — | \<response\> |

## The rule: one criterion ↔ one mechanically checkable assertion

Each `acceptance_checks[]` item — EARS-form or plain-string — verifies exactly
ONE thing. Do not compound two assertions behind a single `AND` inside one
`then`; split into two ids instead. This is what makes `verify_method` possible
at all: a checker (Kupo, or ESL's `drift_check` transition) must be able to run
one test, one gate, or one grep per id and get a binary pass/fail. A criterion
that silently bundles two behaviors cannot be re-derived unambiguously later —
which defeats §6.4's `drift_check` re-derivation requirement.

## Frozen at spec time (hashed)

Acceptance criteria are **frozen** the moment Assemble emits the spec — they are
not meant to drift silently while `in_progress`/`verified` work proceeds against
them. At Assemble, compute the SHA-256 of the acceptance-criteria content
(the full worked set for this spec, not just this template's boilerplate) and
carry it on the ECL spec envelope as the `x_spectra_acceptance_criteria` vendor
extension (ECL §1.2.3 — receivers unaware of it ignore it safely):

```json
"x_spectra_acceptance_criteria": {
  "path": ".spectra/plans/{date}-{feature}.acceptance.md",
  "sha256": "<64-hex-chars sha256 of that file's bytes at spec time>"
}
```

A downstream verifier (Kupo at `verified`, or ESL's `drift_check` transition at
`archived`) can recompute this digest and prove the checks it ran are the exact
set frozen at spec time — not a set silently edited after the fact. See
`templates/spec.envelope.json` and `skills/planning/SKILL.md` "Acceptance criteria".

## Worked examples

**Example 1 — Event-driven** (form #2):

```yaml
- id: AC-1
  when: "a GET request arrives at /healthz"
  then: "the endpoint SHALL respond within 200ms with HTTP 200 and body {\"status\":\"<ok|degraded>\",\"version\":\"<semver>\"}"
  verify_method: "test: spec/requests/healthz_spec.rb#responds_ok"
```

**Example 2 — Unwanted behavior** (form #4):

```yaml
- id: AC-2
  given: "the database connection pool is exhausted"
  when: "IF a health check probe times out after 2s"
  then: "the endpoint SHALL respond HTTP 503 with {\"status\":\"degraded\",\"reason\":\"db_timeout\"}, never HTTP 200"
  verify_method: "test: spec/requests/healthz_spec.rb#responds_degraded_on_db_timeout"
```

**Example 3 — State-driven** (form #3):

```yaml
- id: AC-3
  given: "the service is running in maintenance mode (MAINTENANCE_MODE=true)"
  then: "the endpoint SHALL respond HTTP 200 with {\"status\":\"maintenance\"} regardless of downstream dependency health"
  verify_method: "test: spec/requests/healthz_spec.rb#responds_maintenance_when_flagged"
```

## What this template does NOT do

- It does not replace `docs/spectra-methodology/catalog.md`'s Story Format —
  it is an optional structured form for the `Acceptance Criteria:` block
  already defined there.
- It does not re-declare ESL's `change.v1.json` schema — the field names
  (`id`, `given`, `when`, `then`, `verify_method`) are referenced by version,
  not redefined here (ESL 1.1 §2.5; ESL MUST NOT re-declare SPECTRA's
  GIVEN/WHEN/THEN format, and SPECTRA correspondingly does not re-declare
  ESL's manifest schema).
- It is never a gate. ESL's C7 check (`conformance/esl-conformance.sh`,
  SHOULD-level) lints EARS-form items for completeness and warns on a
  missing field — it never blocks, and non-EARS items produce no finding.

---

*SPECTRA — Acceptance Criteria Template (EARS form, optional)*
