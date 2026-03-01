# Example: Player Import Feature (Ruby on Rails)

> **Stack context:** This example uses Ruby on Rails conventions (FlowObjects, Repositories, ViewComponents). SPECTRA was originally developed and tested on Rails applications. See `generic-api-feature.md` for a stack-agnostic example using the same methodology.

Full specification demonstrating all SPECTRA phases.

---

## Scope Analysis

```markdown
## 🎯 SCOPE ANALYSIS

**Intent Type:** REQUEST
**Complexity Score:** 7/12
**Thinking Budget:** Extended

**WHO:** Tournament Organizer
**WHAT:** Bulk import players from CSV with validation
**WHY:** Reduce manual roster entry time by 90%
**CONSTRAINTS:** Must handle 10K+ players, preserve existing rankings

**Boundaries:**
| In Scope | Out of Scope | Deferred |
|----------|--------------|----------|
| CSV parsing | Excel support | API import |
| Validation | Deduplication | Real-time sync |
| Error reporting | Auto-correction | — |

**Assumptions:**
1. CSV format is standardized — Risk: custom formats need mapping
2. Gamertags are unique identifiers — Risk: duplicates cause conflicts
```

## Pattern Analysis

```markdown
## 📚 PATTERN ANALYSIS

**Query:** "player import CSV batch processing"
**Matches:** 3 patterns

| ID | Pattern | Similarity | Decision |
|----|---------|------------|----------|
| P1 | TeamRosterImportFlow | 82% | ADAPT |
| P2 | CsvProcessingService | 75% | CONTEXT_ONLY |
| P3 | BulkPlayerCreate | 68% | CONTEXT_ONLY |

**Strategy:** ADAPT (TeamRosterImportFlow)
**Adaptations:** Add validation layer, change entity type
```

## Exploration Summary

```markdown
## 🌳 EXPLORATION SUMMARY

**Hypotheses:** 4 generated, top 2 expanded

| # | Name | Feas | Value | Risk | Pattern | Timebox | Total |
|---|------|------|-------|------|---------|---------|-------|
| 1 | Streaming + FlowObject | 3 | 3 | 2 | 3 | 3 | 14 |
| 2 | Batch Worker Pipeline | 2 | 3 | 3 | 2 | 2 | 12 |
| 3 | Direct ActiveRecord | 3 | 2 | 1 | 1 | 3 | 10 |
| 4 | External ETL Service | 1 | 3 | 2 | 1 | 1 | 8 |

**Selected:** H1 — Streaming + FlowObject
**Rationale:** Best pattern fit, contained risk, memory-efficient for large files
**Rejected:** H2 (infrastructure overhead), H3 (N+1 risk at scale), H4 (scope creep)
```

## Story (Action Plan Format)

```markdown
#### 📋 STORY: S-1 Create PlayerImport FlowObject

> 🔵 Adapts TeamRosterImportFlow pattern

**Description:** As a Tournament Organizer, I want to import players from CSV so that I can set up tournaments faster
**Timebox:** ≤3d
**Risk:** P1

## Action Plan:
1. **Create:** `Players::Import` FlowObject at `app/models/players/import.rb`
2. **Create:** `Players::ImportValidator` for row validation
3. **Extend:** `Players::Repository` with `bulk_create` method
4. **Create:** ViewComponent for import UI with progress
5. **Test:** Success path, validation failures, large file handling

## Acceptance Criteria:
- [ ] GIVEN valid CSV WHEN imported THEN all players created
- [ ] GIVEN invalid rows WHEN imported THEN errors reported per row
- [ ] GIVEN 10K+ rows WHEN imported THEN completes under 60s
- [ ] GIVEN duplicate gamertag WHEN imported THEN row flagged, not created

## Technical Context:
- **Pattern:** FlowObject with streaming CSV parser
- **Files:** `app/models/players/import.rb`, `app/models/players/repository.rb`
- **Dependencies:** CSV stdlib, existing Player model

## Agent Hints:
- **Class:** builder (speed-class)
- **Context:** `app/models/rosters/import.rb` (exemplar)
- **Gates:** P0 checked, ≥85% coverage, handles 10K+ rows
```

## Confidence Report

```markdown
## 📊 CONFIDENCE ASSESSMENT

| Factor | Score |
|--------|-------|
| Pattern Match | 2.5/3 |
| Requirement Clarity | 2/3 |
| Decomposition Stability | 3/3 |
| Constraint Compliance | 3/3 |

**Weighted Confidence:** 87%
**Decision:** AUTO_PROCEED

**Gaps:**
- Edge case: malformed UTF-8 — assumed skip row, risk: data loss
```

## Agent Handoff (YAML)

```yaml
metadata:
  spec_id: "SPEC-2025-01-13-001"
  confidence: 87
  complexity: 7
  refinement_cycles: 1
  spectra_version: "4.1.0"

projects:
  - id: "P-1"
    name: "Player Import"
    features:
      - id: "F-1"
        name: "CSV Import"
        stories:
          - id: "S-1"
            title: "Create PlayerImport FlowObject"
            timebox: "≤3d"
            risk: "P1"
            action_plan:
              - verb: "Create"
                target: "Players::Import FlowObject"
              - verb: "Create"
                target: "Players::ImportValidator"
              - verb: "Extend"
                target: "Players::Repository.bulk_create"
              - verb: "Test"
                target: "All paths with 10K+ stress test"
            acceptance_criteria:
              - given: "valid CSV"
                when: "imported"
                then: "all players created"
              - given: "invalid rows"
                when: "imported"
                then: "errors reported per row"
            agent_hints:
              recommended_class: "builder"
              context_files:
                - "app/models/rosters/import.rb"
                - "app/models/players/repository.rb"
              validation_gates:
                p0: "No ActiveRecord in FlowObject"
                coverage: "≥85%"
                performance: "10K rows < 60s"

execution_plan:
  phases:
    - name: "Core Import"
      stories: ["S-1"]
      agent_class: "builder"
```

---

*This example uses Ruby on Rails conventions. The SPECTRA methodology applies identically to any stack — only the domain vocabulary changes.*
