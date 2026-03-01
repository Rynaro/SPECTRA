# SPECTRA Anti-Patterns

What NOT to do. Each anti-pattern includes why it fails and the correct alternative.

---

## ❌ Using "Epic" instead of "Project"

```markdown
#### EPIC: User Management System
```

**Why it fails:** "Epic" is an overloaded Agile term with inconsistent meaning across teams. SPECTRA uses a strict hierarchy: Theme → Project → Feature → Story → Task.

**Correct:**
```markdown
## 📦 PROJECT: User Management System
```

---

## ❌ Using story points instead of timeboxes

```markdown
**Points:** Large (8-13)
```

**Why it fails:** Story points measure relative effort, not calendar time. They require team-specific calibration that doesn't exist in AI-agent contexts. Timeboxes are universally interpretable.

**Correct:**
```markdown
**Timebox:** ≤5d
```

---

## ❌ Vague stories without INVEST

```markdown
**Description:** Build the user management system
**Tasks:**
- Do the backend
- Do the frontend
```

**Why it fails:** Not Independent (combined), not Negotiable (no flexibility), not Valuable (what value?), not Estimable (how long?), not Small (entire system), not Testable (no criteria).

**Correct:**
```markdown
#### 📋 STORY: S-1 Create User Registration Service

**Description:** As a visitor, I want to register so that I can access the platform
**Timebox:** ≤2d

## Action Plan:
1. **Create:** `UserRegistrationService` with email/password validation
2. **Create:** POST `/auth/register` endpoint with rate limiting
3. **Test:** Success + validation failure + duplicate email + rate limit

## Acceptance Criteria:
- [ ] GIVEN valid email/password WHEN POST /auth/register THEN user created, 201 returned
- [ ] GIVEN duplicate email WHEN POST /auth/register THEN 409 returned
- [ ] GIVEN weak password WHEN POST /auth/register THEN 422 with requirements
```

---

## ❌ Skipping the Explore phase

```markdown
## Going with approach A because it seems right
```

**Why it fails:** PlanSearch research (Wang et al.) shows that plan diversity nearly doubles performance. Single-hypothesis planning leaves quality on the table and misses non-obvious alternatives.

**Correct:** Always generate 3–5 genuinely distinct hypotheses, score them, and select with explicit rationale.

---

## ❌ Stories exceeding 8 days without decomposition

```markdown
**Timebox:** ≤12d
```

**Why it fails:** Stories longer than 8 days have low estimation confidence and are almost certainly hiding independent sub-deliverables. They can't be meaningfully tracked or validated.

**Correct:** Decompose into ≤8d stories. If you can't decompose, it's likely a Project or Feature, not a Story.

---

## ❌ Delivering specs without agent hints

```markdown
## No hints about who should execute this or what context they need
```

**Why it fails:** The executing agent (or human) starts cold with no context about which files to read, what patterns to follow, or what validation gates to check. This forces redundant exploration.

**Correct:**
```markdown
## Agent Hints:
- **Class:** builder (speed-class)
- **Context:** `src/services/existingExample.ts` (exemplar)
- **Gates:** P0 checked, backward-compatible, tests cover success+failure
```

---

## ❌ Plans as chat messages instead of artifacts

```markdown
User: "Plan the feature"
AI: "Here's what I'd do: first we... then we..."
User: "OK do it"
AI: (starts coding, has already forgotten half the plan)
```

**Why it fails:** Chat messages don't survive context windows. When the agent hits context limits or starts a new session, the plan is gone. Research shows persistent plan artifacts dramatically improve execution fidelity.

**Correct:** Save plans as files (`plans/{date}-{feature}.md`). Load state file on re-entry. Plan artifacts are versioned, editable, and survive context resets.

---

## ❌ Refinement without diagnosis

```markdown
## 🔄 REFINEMENT
- Made it better
- Improved clarity
- Fixed some things
```

**Why it fails:** Generic "make it better" refinement moves scores sideways. Without diagnosing what specifically failed and why, each cycle addresses symptoms instead of root causes (Reflexion research, Shinn et al.).

**Correct:**
```markdown
## 🔄 REFINEMENT LOG

### Cycle 1
**Diagnosis:** Story S-3 has ambiguous acceptance criteria — "should handle errors" is not testable
**Root Cause:** Missing edge case analysis during Construct phase
**Prescription:** Add GIVEN/WHEN/THEN for: network timeout, malformed response, rate limit

| Dimension | Before | After | Change |
|-----------|--------|-------|--------|
| Testability | 2 | 4 | Added 3 specific error scenarios |
```

---

*These anti-patterns apply regardless of stack or toolchain.*
