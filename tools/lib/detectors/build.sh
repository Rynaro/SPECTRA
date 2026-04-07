#!/usr/bin/env bash
# lib/detectors/build.sh — Build Tool & Package Manager Detectors
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

detect_build_make() {
  [[ -f "${PROJECT_ROOT}/Makefile" ]] && echo "Make"
}

detect_build_docker() {
  [[ -f "${PROJECT_ROOT}/Dockerfile" || \
     -f "${PROJECT_ROOT}/docker-compose.yml" || \
     -f "${PROJECT_ROOT}/docker-compose.yaml" ]] && echo "Docker"
}

detect_build_npm() {
  [[ -f "${PROJECT_ROOT}/package-lock.json" ]] && echo "npm"
}

detect_build_yarn() {
  [[ -f "${PROJECT_ROOT}/yarn.lock" ]] && echo "Yarn"
}

detect_build_pnpm() {
  [[ -f "${PROJECT_ROOT}/pnpm-lock.yaml" ]] && echo "pnpm"
}

detect_build_bun() {
  [[ -f "${PROJECT_ROOT}/bun.lockb" || -f "${PROJECT_ROOT}/bun.lock" ]] && echo "Bun"
}

detect_build_bundler() {
  [[ -f "${PROJECT_ROOT}/Gemfile.lock" ]] && echo "Bundler"
}

detect_build_poetry() {
  [[ -f "${PROJECT_ROOT}/poetry.lock" ]] && echo "Poetry"
}

detect_build_cargo() {
  [[ -f "${PROJECT_ROOT}/Cargo.lock" ]] && echo "Cargo"
}

detect_build_gomod() {
  [[ -f "${PROJECT_ROOT}/go.sum" ]] && echo "Go modules"
}

detect_build_turborepo() {
  [[ -f "${PROJECT_ROOT}/turbo.json" ]] && echo "Turborepo"
}

detect_build_nx() {
  [[ -f "${PROJECT_ROOT}/nx.json" ]] && echo "Nx"
}

detect_build_bazel() {
  [[ -f "${PROJECT_ROOT}/BUILD" || -f "${PROJECT_ROOT}/BUILD.bazel" || -f "${PROJECT_ROOT}/WORKSPACE" ]] && echo "Bazel"
}

register_detector "build" "make"      "detect_build_make"
register_detector "build" "docker"    "detect_build_docker"
register_detector "build" "npm"       "detect_build_npm"
register_detector "build" "yarn"      "detect_build_yarn"
register_detector "build" "pnpm"      "detect_build_pnpm"
register_detector "build" "bun"       "detect_build_bun"
register_detector "build" "bundler"   "detect_build_bundler"
register_detector "build" "poetry"    "detect_build_poetry"
register_detector "build" "cargo"     "detect_build_cargo"
register_detector "build" "gomod"     "detect_build_gomod"
register_detector "build" "turborepo" "detect_build_turborepo"
register_detector "build" "nx"        "detect_build_nx"
register_detector "build" "bazel"     "detect_build_bazel"
