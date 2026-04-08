#!/usr/bin/env bash
# lib/detectors/testing.sh — Test Framework Detectors
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

detect_test_ruby() {
  local tf=""
  [[ -d "${PROJECT_ROOT}/spec" ]] && tf="${tf}RSpec, "
  [[ -d "${PROJECT_ROOT}/test" && -f "${PROJECT_ROOT}/Gemfile" ]] && \
    grep -qi "minitest" "${PROJECT_ROOT}/Gemfile" 2>/dev/null && tf="${tf}Minitest, "
  echo "${tf%, }"
}

detect_test_node() {
  [[ -f "${PROJECT_ROOT}/package.json" ]] || return 0
  local tf="" pkg="${PROJECT_ROOT}/package.json"
  grep -qi '"jest"'       "$pkg" 2>/dev/null && tf="${tf}Jest, "
  grep -qi '"vitest"'     "$pkg" 2>/dev/null && tf="${tf}Vitest, "
  grep -qi '"mocha"'      "$pkg" 2>/dev/null && tf="${tf}Mocha, "
  grep -qi '"playwright"' "$pkg" 2>/dev/null && tf="${tf}Playwright, "
  grep -qi '"cypress"'    "$pkg" 2>/dev/null && tf="${tf}Cypress, "
  echo "${tf%, }"
}

detect_test_python() {
  [[ -f "${PROJECT_ROOT}/pyproject.toml" ]] || return 0
  grep -qi "pytest" "${PROJECT_ROOT}/pyproject.toml" 2>/dev/null && echo "pytest"
}

detect_test_go() {
  find "${PROJECT_ROOT}" -maxdepth 3 -name "*_test.go" 2>/dev/null | head -1 | grep -q . && echo "Go testing"
}

detect_test_rust() {
  grep -rq '#\[cfg(test)\]' "${PROJECT_ROOT}" --include="*.rs" 2>/dev/null && echo "Rust tests"
}

detect_test_elixir() {
  [[ -d "${PROJECT_ROOT}/test" && -f "${PROJECT_ROOT}/mix.exs" ]] && echo "ExUnit"
}

detect_test_php() {
  [[ -f "${PROJECT_ROOT}/phpunit.xml" || -f "${PROJECT_ROOT}/phpunit.xml.dist" ]] && echo "PHPUnit"
}

register_detector "test" "ruby"   "detect_test_ruby"
register_detector "test" "node"   "detect_test_node"
register_detector "test" "python" "detect_test_python"
register_detector "test" "go"     "detect_test_go"
register_detector "test" "rust"   "detect_test_rust"
register_detector "test" "elixir" "detect_test_elixir"
register_detector "test" "php"    "detect_test_php"
