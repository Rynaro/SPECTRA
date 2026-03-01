# Example: User Notification Preferences API (Generic / Node.js)

> **Stack context:** This example uses a generic Node.js/TypeScript API. It demonstrates that SPECTRA works identically regardless of stack — only the domain vocabulary in stories and action plans changes.

Specification for adding user notification preferences to an existing REST API.

---

## Scope Analysis

```markdown
## 🎯 SCOPE ANALYSIS

**Intent Type:** REQUEST
**Complexity Score:** 6/12
**Thinking Budget:** Standard

**WHO:** API Consumer (mobile app, web dashboard)
**WHAT:** CRUD endpoints for user notification preferences (email, push, SMS toggles per event type)
**WHY:** Users complain about notification spam; need granular control
**CONSTRAINTS:** Must be backward-compatible, existing users default to all-on

**Boundaries:**
| In Scope | Out of Scope | Deferred |
|----------|--------------|----------|
| Preferences CRUD | Notification delivery logic | Preference templates |
| Per-event toggles | Channel verification (email valid?) | Batch preference import |
| Default handling | Push token management | Analytics dashboard |

**Assumptions:**
1. Event types are a known, finite enum — Risk: new events need migration
2. One preference set per user — Risk: multi-org users need per-org prefs
```

## Exploration Summary

```markdown
## 🌳 EXPLORATION SUMMARY

**Hypotheses:** 3 generated, top 2 expanded

| # | Name | Feas | Value | Risk | Pattern | Timebox | Total |
|---|------|------|-------|------|---------|---------|-------|
| 1 | JSONB column + Service | 3 | 3 | 3 | 2 | 3 | 14 |
| 2 | Separate prefs table | 3 | 3 | 2 | 3 | 2 | 13 |
| 3 | Key-value store (Redis) | 2 | 2 | 1 | 1 | 3 | 9 |

**Selected:** H1 — JSONB column + Service Layer
**Rationale:** Simplest schema change, single query per user, flexible for new event types
**Rejected:** H2 (extra join on every notification check), H3 (unnecessary infrastructure)
```

## Stories

```markdown
#### 📋 STORY: S-1 Add notification_preferences column and service

**Description:** As an API consumer, I want to GET/PUT notification preferences so that users can control what notifications they receive
**Timebox:** ≤2d
**Risk:** P1

## Action Plan:
1. **Create:** Migration adding `notification_preferences` JSONB column to `users` table with default
2. **Create:** `NotificationPreferenceService` at `src/services/notificationPreference.service.ts`
3. **Create:** Zod schema for preference validation at `src/schemas/notificationPreference.schema.ts`
4. **Create:** `GET /users/:id/preferences` and `PUT /users/:id/preferences` endpoints
5. **Create:** Integration tests covering default behavior, partial update, invalid input
6. **Extend:** OpenAPI spec with new endpoints

## Acceptance Criteria:
- [ ] GIVEN new user WHEN GET preferences THEN returns all-on defaults
- [ ] GIVEN valid partial update WHEN PUT preferences THEN merges with existing
- [ ] GIVEN invalid event type WHEN PUT preferences THEN returns 422 with details
- [ ] GIVEN existing user WHEN migration runs THEN preferences default to all-on (backward compat)

## Technical Context:
- **Pattern:** Service + Schema Validation + RESTful endpoints
- **Files:** `src/services/`, `src/routes/users.ts`, `migrations/`
- **Dependencies:** Zod, existing User model, PostgreSQL JSONB

## Agent Hints:
- **Class:** builder (speed-class)
- **Context:** `src/services/userProfile.service.ts` (similar CRUD pattern)
- **Gates:** Migration reversible, API backward-compatible, 422 on bad input
```

```markdown
#### 📋 STORY: S-2 Wire preferences into notification dispatcher

**Description:** As the notification system, I want to check preferences before sending so that users only receive notifications they opted into
**Timebox:** ≤2d
**Risk:** P0

## Action Plan:
1. **Extend:** `NotificationDispatcher.send()` to check preferences before dispatch
2. **Create:** Unit tests for preference-gated dispatch (opted-in, opted-out, default)
3. **Test:** End-to-end: set preference OFF → trigger event → verify no notification

## Acceptance Criteria:
- [ ] GIVEN user opts out of email for event_type X WHEN X fires THEN no email sent
- [ ] GIVEN user has no preferences (new) WHEN any event fires THEN all channels send (default on)
- [ ] GIVEN user opts out of ALL channels for X WHEN X fires THEN no notification of any kind

## Agent Hints:
- **Class:** builder (speed-class)
- **Context:** `src/services/notificationDispatcher.ts`
- **Gates:** P0 — must not break existing notification flow for users without preferences
```

## Confidence Report

```markdown
## 📊 CONFIDENCE ASSESSMENT

| Factor | Score |
|--------|-------|
| Pattern Match | 2/3 |
| Requirement Clarity | 2.5/3 |
| Decomposition Stability | 3/3 |
| Constraint Compliance | 3/3 |

**Weighted Confidence:** 88%
**Decision:** AUTO_PROCEED

**Gaps:**
- Multi-org preference scoping deferred — document as future consideration
```

---

*This example uses Node.js/TypeScript conventions. The SPECTRA methodology applies identically to any stack.*
