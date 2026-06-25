---
name: spectra-esl-hop
description: "ESL lifecycle hop — when the cortex routes a non-trivial change to SPECTRA in an ESL-enabled project (tonberry MCP available), SPECTRA owns the proposed→specify hop: right-size, propose the change folder, emit the spec into it. Absent tonberry → produce the spec normally (ESL opt-in)."
metadata:
  methodology: SPECTRA
---

# SPECTRA — ESL Lifecycle Hop

Use this skill in an **ESL-enabled project** (`mcp__tonberry__*` tools available)
when the cortex routes a non-trivial change to you. You own the
**proposed → specify** hop of the Eidolons Spec Lifecycle (ESL).

For the full lifecycle, stage definitions, and role bindings, see the nexus
cortex `methodology/cortex/esl-protocol.md`.

## Your hop

1. **right_size** — call `mcp__tonberry__right_size`. Provide your /12 complexity
   score, a files-touched estimate, and the trade-off rationale. Tonberry returns
   the tier. Trivial work routes to **Kupo**, not you; you take **lite** or
   **full**.
2. **propose** — call
   `mcp__tonberry__propose --change_id <id> --maker vivi --checker <kupo|vigil> --has_code <bool>`.
   This scaffolds `.spectra/changes/<id>/change.json`.
3. **specify** — run your normal **S → P → E → C → T → R → A** cycle and emit the
   spec **into the change folder**:
   - **lite** → one-page `spec.md` (GIVEN / WHEN / THEN + acceptance_checks).
   - **full** → `spec.{md,yaml}` (the standard dual-format SPECTRA spec).
4. **compose_manifest** — call `mcp__tonberry__compose_manifest` to set `tier`
   and `acceptance_checks` (ids referencing your GIVEN / WHEN / THEN) in
   `change.json`.
5. **hand off** to the implementer (**Vivi** at `in_progress`) with your normal
   ECL `PROPOSE` envelope (see `skills/planning.md` "ECL emission").

## Invariants

- **maker(vivi) ≠ checker(kupo/vigil)** — distinct roles, always.
- **Tonberry composes artifacts; you provide spec content + signals.** You supply
  the /12 score, the spec text, and the acceptance-check ids; tonberry writes the
  `change.json` structure.
- **Graceful skip** — if `mcp__tonberry__*` tools are unavailable, produce the
  spec normally via your standard cycle and **never hard-fail**. ESL is opt-in;
  SPECTRA is EIIS-standalone-conformant and works without tonberry.

---

*SPECTRA — ESL Lifecycle Hop*
