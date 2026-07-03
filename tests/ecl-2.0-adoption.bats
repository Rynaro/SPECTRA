#!/usr/bin/env bats
# tests/ecl-2.0-adoption.bats — ECL v2.0 adoption sweep (Wave-3)
#
# Covers: the vendored v2 envelope schema (retaining v1 for the ECL §7.3
# back-compat window), ISE (Intent, Source, Entitlement) block presence on
# the outbound spec envelope template and the vendored schema's $defs.ise,
# install.sh wiring for the new schema file and the new EARS
# acceptance-criteria template, the EARS template's own content contract,
# canonical verify-incoming convergence with ../Kupo, drift-kill greps (no
# stray "ECL v1.0" prose left behind by the sweep), and the 5-canonical-homes
# version stamp.

load helpers.bash

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
INSTALL_DIR=""

setup() {
  INSTALL_DIR=""
}

teardown() {
  teardown_install
}

# ─────────────────────────────────────────────────────────────────────────────
# v2 envelope schema — vendored, valid, v1 retained
# ─────────────────────────────────────────────────────────────────────────────

@test "v2: schemas/ecl-envelope.v2.json exists and is valid JSON" {
  [ -f "${REPO_ROOT}/schemas/ecl-envelope.v2.json" ]
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq empty "${REPO_ROOT}/schemas/ecl-envelope.v2.json"
  [ "$status" -eq 0 ]
}

@test "v2: schemas/ecl-envelope.v1.json is RETAINED (not removed by the sweep)" {
  [ -f "${REPO_ROOT}/schemas/ecl-envelope.v1.json" ]
  if command -v jq &>/dev/null; then
    run jq empty "${REPO_ROOT}/schemas/ecl-envelope.v1.json"
    [ "$status" -eq 0 ]
  fi
}

@test "v2: envelope_version pattern accepts both 1.x (compat window) and 2.0" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.properties.envelope_version.pattern' "${REPO_ROOT}/schemas/ecl-envelope.v2.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"2"*"0"* ]]
  [[ "$output" == *"1"* ]]
}

@test "v2: schema declares an ise \$defs block requiring assertion_grade" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.["$defs"].ise.required[0]' "${REPO_ROOT}/schemas/ecl-envelope.v2.json"
  [ "$status" -eq 0 ]
  [ "$output" = "assertion_grade" ]
}

@test "v2: ise.assertion_grade enum has the four ECL v2.0 §6.5.1 values" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.["$defs"].ise.properties.assertion_grade.enum | sort | join(",")' "${REPO_ROOT}/schemas/ecl-envelope.v2.json"
  [ "$status" -eq 0 ]
  [ "$output" = "human-reviewed,self-attested,unverified,validated" ]
}

@test "v2: top-level ise property refs the \$defs/ise block" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.properties.ise["$ref"]' "${REPO_ROOT}/schemas/ecl-envelope.v2.json"
  [ "$status" -eq 0 ]
  [ "$output" = "#/\$defs/ise" ]
}

@test "v2: schema permits x_spectra_acceptance_criteria vendor extension via patternProperties" {
  grep -qF '^x_[a-z][a-z0-9_]*$' "${REPO_ROOT}/schemas/ecl-envelope.v2.json"
}

# ─────────────────────────────────────────────────────────────────────────────
# install.sh wiring — v2 schema + EARS template
# ─────────────────────────────────────────────────────────────────────────────

@test "install.sh copies schemas/ecl-envelope.v2.json (alongside v1)" {
  grep -q 'ecl-envelope.v2.json' "${REPO_ROOT}/install.sh"
  grep -q 'ecl-envelope.v1.json' "${REPO_ROOT}/install.sh"
}

@test "install.sh copies templates/acceptance-criteria.md" {
  grep -q 'SRC_ACCEPTANCE_CRITERIA' "${REPO_ROOT}/install.sh"
  grep -q 'templates/acceptance-criteria.md' "${REPO_ROOT}/install.sh"
}

@test "install.sh validates acceptance-criteria.md as a required source file" {
  grep -q 'SRC_ACCEPTANCE_CRITERIA"' "${REPO_ROOT}/install.sh"
}

@test "install.sh exits 0 and produces both schema versions + the EARS template in target" {
  # NOTE: call the helper directly (not via `run`) — `run` forks a subshell,
  # so INSTALL_TARGET/INSTALL_MANIFEST assigned inside the helper would not
  # survive back into this test body. install.sh's own exit-0 contract is
  # already covered by the sibling "install.sh exits 0 ..." test below and
  # in tests/verify-incoming.bats.
  run_install_into_tmpdir
  [ -f "${INSTALL_TARGET}/schemas/ecl-envelope.v1.json" ]
  [ -f "${INSTALL_TARGET}/schemas/ecl-envelope.v2.json" ]
  [ -f "${INSTALL_TARGET}/templates/acceptance-criteria.md" ]
}

@test "install.sh exits 0 with the new ECL v2 + EARS files present" {
  run run_install_into_tmpdir
  [ "$status" -eq 0 ]
}

@test "install manifest records templates/acceptance-criteria.md in files_written with a sha256" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run_install_into_tmpdir
  run jq -r '[.files_written[] | select(.path | test("acceptance-criteria.md$"))][0].sha256' "${INSTALL_MANIFEST}"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  [ "$output" != "null" ]
}

@test "install manifest records both ecl-envelope schema versions in files_written" {
  run_install_into_tmpdir
  grep -q 'ecl-envelope.v1.json' "${INSTALL_MANIFEST}"
  grep -q 'ecl-envelope.v2.json' "${INSTALL_MANIFEST}"
}

@test "install manifest ecl_version_emitted is 2.0" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run_install_into_tmpdir
  run jq -r '.ecl_version_emitted' "${INSTALL_MANIFEST}"
  [ "$status" -eq 0 ]
  [ "$output" = "2.0" ]
}

# ─────────────────────────────────────────────────────────────────────────────
# ISE — outbound spec envelope template
# ─────────────────────────────────────────────────────────────────────────────

@test "ise: templates/spec.envelope.json declares envelope_version 2.0" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.envelope_version' "${REPO_ROOT}/templates/spec.envelope.json"
  [ "$status" -eq 0 ]
  [ "$output" = "2.0" ]
}

@test "ise: templates/spec.envelope.json ise.assertion_grade is self-attested" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.ise.assertion_grade' "${REPO_ROOT}/templates/spec.envelope.json"
  [ "$status" -eq 0 ]
  [ "$output" = "self-attested" ]
}

@test "ise: templates/spec.envelope.json receiver_authorization matches the declared defaults" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.ise.receiver_authorization.auto_route' "${REPO_ROOT}/templates/spec.envelope.json"
  [ "$output" = "true" ]
  run jq -r '.ise.receiver_authorization.auto_merge' "${REPO_ROOT}/templates/spec.envelope.json"
  [ "$output" = "false" ]
  run jq -r '.ise.receiver_authorization.auto_deploy' "${REPO_ROOT}/templates/spec.envelope.json"
  [ "$output" = "false" ]
}

@test "ise: templates/spec.envelope.json provenance.methodology_version starts with spectra-" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.ise.provenance.methodology_version' "${REPO_ROOT}/templates/spec.envelope.json"
  [ "$status" -eq 0 ]
  case "$output" in
    spectra-*) : ;;
    *) echo "expected 'spectra-*', got '$output'" >&2; return 1 ;;
  esac
}

@test "ise: templates/spec.envelope.json carries the optional x_spectra_acceptance_criteria field" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -e '.x_spectra_acceptance_criteria.sha256' "${REPO_ROOT}/templates/spec.envelope.json"
  [ "$status" -eq 0 ]
}

@test "ise: skills/planning.md ECL emission gate requires the ise block" {
  grep -q 'ise.assertion_grade: "self-attested"' "${REPO_ROOT}/skills/planning.md"
}

# ─────────────────────────────────────────────────────────────────────────────
# EARS acceptance-criteria template — content contract
# ─────────────────────────────────────────────────────────────────────────────

@test "ears: templates/acceptance-criteria.md exists with canonical template frontmatter" {
  local f="${REPO_ROOT}/templates/acceptance-criteria.md"
  [ -f "$f" ]
  grep -q '^artifact: acceptance-criteria' "$f"
}

@test "ears: template declares all five canonical EARS sentence forms" {
  local f="${REPO_ROOT}/templates/acceptance-criteria.md"
  grep -qi 'Ubiquitous' "$f"
  grep -qi 'Event-driven' "$f"
  grep -qi 'State-driven' "$f"
  grep -qi 'Unwanted behavior' "$f"
  grep -qi 'Optional feature' "$f"
}

@test "ears: template maps forms onto given/when/then/id/verify_method" {
  local f="${REPO_ROOT}/templates/acceptance-criteria.md"
  grep -q 'given' "$f"
  grep -q 'when' "$f"
  grep -q 'then' "$f"
  grep -q 'verify_method' "$f"
}

@test "ears: template states the one-criterion-one-assertion rule" {
  grep -qi 'one criterion' "${REPO_ROOT}/templates/acceptance-criteria.md"
}

@test "ears: template states criteria are frozen (hashed) at spec time" {
  grep -qi 'frozen' "${REPO_ROOT}/templates/acceptance-criteria.md"
  grep -q 'sha256\|SHA-256' "${REPO_ROOT}/templates/acceptance-criteria.md"
}

@test "ears: template references the x_spectra_acceptance_criteria envelope field" {
  grep -q 'x_spectra_acceptance_criteria' "${REPO_ROOT}/templates/acceptance-criteria.md"
}

@test "ears: template carries at least 3 worked examples with id: AC-N" {
  local f="${REPO_ROOT}/templates/acceptance-criteria.md"
  run grep -c 'id: AC-' "$f"
  [ "$status" -eq 0 ]
  [ "$output" -ge 3 ]
}

@test "ears: template is additive — states plain-string/minimal forms remain fully valid" {
  grep -qi 'remain.*valid\|100% valid' "${REPO_ROOT}/templates/acceptance-criteria.md"
}

@test "ears: template states it never blocks (C7 is advisory)" {
  grep -qi 'never block' "${REPO_ROOT}/templates/acceptance-criteria.md"
}

@test "ears: skills/planning.md references the EARS template additively, without rewriting scoring.md" {
  grep -q 'templates/acceptance-criteria.md' "${REPO_ROOT}/skills/planning.md"
  grep -qi 'ESL 1.1' "${REPO_ROOT}/skills/planning.md"
}

@test "ears: docs/spectra-methodology/scoring.md is unmodified by this sweep (git diff empty)" {
  if ! command -v git &>/dev/null; then
    skip "git not available"
  fi
  cd "${REPO_ROOT}" || return 1
  run git diff --quiet main -- docs/spectra-methodology/scoring.md
  if [ "$status" -ne 0 ] && [ "$status" -ne 1 ]; then
    skip "git diff against 'main' unavailable in this checkout"
  fi
  # status 0 = no diff (unmodified); status 1 = diff present (fail this test).
  [ "$status" -eq 0 ]
}

# ─────────────────────────────────────────────────────────────────────────────
# Canonical verify-incoming convergence with ../Kupo
# ─────────────────────────────────────────────────────────────────────────────

@test "convergence: verify-incoming.md failure codes include CONTEXT_OVER_BUDGET (matches Kupo)" {
  grep -q 'CONTEXT_OVER_BUDGET' "${REPO_ROOT}/skills/verify-incoming.md"
}

@test "convergence: verify-incoming.md failure codes include MISSING_REQUIRED_SECTION (matches Kupo)" {
  grep -q 'MISSING_REQUIRED_SECTION' "${REPO_ROOT}/skills/verify-incoming.md"
}

@test "convergence: verify-incoming.md 'six Eidolons' stale count is gone" {
  run grep -c 'six Eidolons' "${REPO_ROOT}/skills/verify-incoming.md"
  [ "$output" = "0" ]
}

@test "convergence: verify-incoming.md now uses roster-agnostic 'All Eidolons in the roster' phrasing" {
  grep -q 'All Eidolons in the roster ship this gate' "${REPO_ROOT}/skills/verify-incoming.md"
}

@test "convergence: verify-incoming.md accepted-artifact table is preserved (SPECTRA-specific inbound edges)" {
  grep -q 'atlas' "${REPO_ROOT}/skills/verify-incoming.md"
  grep -q 'vigil' "${REPO_ROOT}/skills/verify-incoming.md"
  grep -q 'forge' "${REPO_ROOT}/skills/verify-incoming.md"
  grep -q 'scout-report' "${REPO_ROOT}/skills/verify-incoming.md"
  grep -q 'root-cause-report' "${REPO_ROOT}/skills/verify-incoming.md"
  grep -q 'reasoning-report' "${REPO_ROOT}/skills/verify-incoming.md"
}

@test "convergence: verify-incoming.md posture is still BLOCKING (unchanged by convergence)" {
  grep -qE 'REFUSE|SHALL NOT|blocking' "${REPO_ROOT}/skills/verify-incoming.md"
}

# ─────────────────────────────────────────────────────────────────────────────
# Drift-kill: no stray "ECL v1.0" prose left in documentation
# ─────────────────────────────────────────────────────────────────────────────

@test "drift: no stale 'ECL v1.0' prose remains outside CHANGELOG.md, the retained v1 schema, and the SPEC.md history note" {
  run grep -rn "ECL v1\.0" \
    --include="*.md" --include="*.sh" --include="*.json" \
    "${REPO_ROOT}"
  if [ "$status" -eq 0 ]; then
    local leftover
    leftover="$(printf '%s\n' "$output" \
      | grep -v '/CHANGELOG\.md:' \
      | grep -v '/schemas/ecl-envelope\.v1\.json:' \
      | grep -v '/docs/spectra-methodology/SPEC\.md:404:' \
      || true)"
    [ -z "$leftover" ] || {
      echo "Stale 'ECL v1.0' prose found:"
      echo "$leftover"
      return 1
    }
  fi
}

@test "drift: skills/planning.md ECL emission gate targets ecl-envelope.v2.json" {
  grep -q 'ecl-envelope.v2.json' "${REPO_ROOT}/skills/planning.md"
}

@test "drift: templates/planning-artifact.md ECL section targets v2.0" {
  grep -q '"2.0"' "${REPO_ROOT}/templates/planning-artifact.md"
  grep -q 'ecl-envelope.v2.json' "${REPO_ROOT}/templates/planning-artifact.md"
}

@test "drift: docs/spectra-methodology/SPEC.md ECL Compatibility table declares version 2.0" {
  grep -q '| ECL version | `2.0` |' "${REPO_ROOT}/docs/spectra-methodology/SPEC.md"
}

@test "drift: DESIGN-RATIONALE.md DR-09 documents the self-attested ISE grade" {
  grep -q 'DR-09' "${REPO_ROOT}/DESIGN-RATIONALE.md"
  grep -qi 'self-attested' "${REPO_ROOT}/DESIGN-RATIONALE.md"
}

@test "drift: ECL_VERSION file still declares 2.0 (unchanged — already clean pre-sweep)" {
  [ -f "${REPO_ROOT}/ECL_VERSION" ]
  local ver
  ver="$(tr -d '[:space:]' < "${REPO_ROOT}/ECL_VERSION")"
  [ "$ver" = "2.0" ]
}

# ─────────────────────────────────────────────────────────────────────────────
# Version stamp — 5 canonical homes at 4.11.0
# ─────────────────────────────────────────────────────────────────────────────

@test "stamp: install.sh, agent.md, AGENTS.md, SPEC.md, README.md agree on 4.11.0" {
  grep -q 'EIDOLON_VERSION="4.11.0"' "${REPO_ROOT}/install.sh"
  grep -q 'version: 4.11.0' "${REPO_ROOT}/agent.md"
  grep -q 'methodology_version: 4.11.0' "${REPO_ROOT}/agent.md"
  grep -q 'version: 4.11.0' "${REPO_ROOT}/AGENTS.md"
  grep -q 'methodology_version: 4.11.0' "${REPO_ROOT}/AGENTS.md"
  grep -q 'Eidolon release:\*\* v4.11.0' "${REPO_ROOT}/docs/spectra-methodology/SPEC.md"
  grep -q 'SPECTRA_v4.11' "${REPO_ROOT}/README.md"
}

@test "stamp: install.sh reports the bumped version at runtime" {
  run_install_into_tmpdir
  if command -v jq &>/dev/null; then
    run jq -r '.version' "${INSTALL_MANIFEST}"
    [ "$output" = "4.11.0" ]
  else
    grep -q '"version": "4.11.0"' "${INSTALL_MANIFEST}"
  fi
}

@test "stamp: no OTHER test file hardcodes the previous version 4.10.0 or 4.9.1" {
  # Excludes this file itself, which legitimately names the old versions in
  # its own test descriptions/assertions about the version bump.
  run grep -rln '4\.10\.0\|4\.9\.1' "${REPO_ROOT}/tests/"*.bats
  if [ "$status" -eq 0 ]; then
    local leftover
    leftover="$(printf '%s\n' "$output" | grep -v 'ecl-2.0-adoption.bats' || true)"
    [ -z "$leftover" ] || {
      echo "Stale version hardcoded in:"
      echo "$leftover"
      return 1
    }
  fi
}
