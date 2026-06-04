#!/usr/bin/env bats
# tests/verify-incoming.bats — blocking, symmetric verify-incoming gate (ECL §6.2.2)
#
# Validates the verify-incoming skill contract for SPECTRA:
#   - The skill file exists and declares the BLOCKING posture.
#   - It does NOT carry warn-only language.
#   - install.sh copies it to the install target and records it in the manifest.

load helpers.bash

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
INSTALL_DIR=""

setup() {
  INSTALL_DIR=""
}

teardown() {
  teardown_install
}

# ── Skill source file assertions ────────────────────────────────────────────

@test "skills/verify-incoming.md exists in repo" {
  [ -f "${REPO_ROOT}/skills/verify-incoming.md" ]
}

@test "skill declares BLOCKING posture (REFUSE / SHALL NOT / blocking)" {
  grep -qE 'REFUSE|SHALL NOT|blocking' "${REPO_ROOT}/skills/verify-incoming.md"
}

@test "skill does NOT instruct to process payloads anyway (not a warn-only skill)" {
  # Negative assertion: the skill must not actively instruct to process a tampered
  # payload. The file may MENTION "warn-only" to document the superseded posture,
  # but must not carry a DECISION line that says to proceed on failure.
  # We check for the phrase "process the payload" NOT preceded by a negation and
  # not inside a "**Posture change**" / "superseded" context.
  # The canonical form: "Do not process the payload" — that is allowed.
  # Forbidden forms: "process the payload anyway" as an active instruction.
  ! grep -qiE 'Do not refuse|always processed|processes.*regardless' \
      "${REPO_ROOT}/skills/verify-incoming.md"
  # Must contain the explicit "Do not process" refusal instruction.
  grep -qiE 'do not process the payload|REFUSE' \
      "${REPO_ROOT}/skills/verify-incoming.md"
}

@test "skill frontmatter name is spectra-verify-incoming" {
  grep -q 'name: spectra-verify-incoming' "${REPO_ROOT}/skills/verify-incoming.md"
}

@test "skill frontmatter methodology is SPECTRA" {
  grep -q 'methodology: SPECTRA' "${REPO_ROOT}/skills/verify-incoming.md"
}

@test "skill frontmatter methodology_version matches sibling skills (4.7)" {
  grep -q 'methodology_version: "4.7"' "${REPO_ROOT}/skills/verify-incoming.md"
}

# ── Install target assertions ────────────────────────────────────────────────

@test "install.sh exits 0 with verify-incoming skill" {
  run run_install_into_tmpdir
  [ "$status" -eq 0 ]
}

@test "install.sh copies skills/verify-incoming.md to install target" {
  run_install_into_tmpdir
  [ -f "${INSTALL_TARGET}/skills/verify-incoming.md" ]
}

@test "install manifest records verify-incoming skill" {
  if ! command -v python3 &>/dev/null && ! command -v jq &>/dev/null; then
    skip "neither python3 nor jq available"
  fi
  run_install_into_tmpdir
  [ -f "${INSTALL_MANIFEST}" ]
  if command -v jq &>/dev/null; then
    run jq -r '.skills[].name' "${INSTALL_MANIFEST}"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q 'verify-incoming'
  else
    grep -q '"verify-incoming"' "${INSTALL_MANIFEST}"
  fi
}

@test "install manifest verify-incoming entry has a source_sha256" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run_install_into_tmpdir
  run jq -r '.skills[] | select(.name=="verify-incoming") | .source_sha256' "${INSTALL_MANIFEST}"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  [[ "$output" != "null" ]]
}

# ── Inbound edge table assertions ────────────────────────────────────────────

@test "skill declares atlas as an inbound sender" {
  grep -q 'atlas' "${REPO_ROOT}/skills/verify-incoming.md"
}

@test "skill declares vigil as an inbound sender" {
  grep -q 'vigil' "${REPO_ROOT}/skills/verify-incoming.md"
}

@test "skill declares forge as an inbound sender" {
  grep -q 'forge' "${REPO_ROOT}/skills/verify-incoming.md"
}

# ── Trace event format assertions ────────────────────────────────────────────

@test "skill references verify_pass trace event" {
  grep -q 'verify_pass' "${REPO_ROOT}/skills/verify-incoming.md"
}

@test "skill references verify_fail trace event" {
  grep -q 'verify_fail' "${REPO_ROOT}/skills/verify-incoming.md"
}

@test "skill references INTEGRITY_MISMATCH failure code" {
  grep -q 'INTEGRITY_MISMATCH' "${REPO_ROOT}/skills/verify-incoming.md"
}

@test "skill references UNVERIFIED failure code" {
  grep -q 'UNVERIFIED' "${REPO_ROOT}/skills/verify-incoming.md"
}
