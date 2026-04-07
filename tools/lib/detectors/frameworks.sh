#!/usr/bin/env bash
# lib/detectors/frameworks.sh — Framework Detectors
# Detects web frameworks and application frameworks.
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

detect_framework_ruby() {
  [[ -f "${PROJECT_ROOT}/Gemfile" ]] || return 0
  local fw=""
  grep -qi "rails"  "${PROJECT_ROOT}/Gemfile" 2>/dev/null && fw="${fw}Ruby on Rails, "
  grep -qi "sinatra" "${PROJECT_ROOT}/Gemfile" 2>/dev/null && fw="${fw}Sinatra, "
  grep -qi "hanami" "${PROJECT_ROOT}/Gemfile" 2>/dev/null && fw="${fw}Hanami, "
  echo "${fw%, }"
}

detect_framework_node() {
  [[ -f "${PROJECT_ROOT}/package.json" ]] || return 0
  local fw="" pkg="${PROJECT_ROOT}/package.json"
  grep -qi '"next"'     "$pkg" 2>/dev/null && fw="${fw}Next.js, "
  grep -qi '"nuxt"'     "$pkg" 2>/dev/null && fw="${fw}Nuxt, "
  grep -qi '"express"'  "$pkg" 2>/dev/null && fw="${fw}Express, "
  grep -qi '"fastify"'  "$pkg" 2>/dev/null && fw="${fw}Fastify, "
  grep -qi '"@nestjs'   "$pkg" 2>/dev/null && fw="${fw}NestJS, "
  grep -qi '"react"'    "$pkg" 2>/dev/null && fw="${fw}React, "
  grep -qi '"vue"'      "$pkg" 2>/dev/null && fw="${fw}Vue, "
  grep -qi '"svelte"'   "$pkg" 2>/dev/null && fw="${fw}Svelte, "
  grep -qi '"@sveltejs/kit"' "$pkg" 2>/dev/null && fw="${fw}SvelteKit, "
  grep -qi '"angular'   "$pkg" 2>/dev/null && fw="${fw}Angular, "
  grep -qi '"remix"'    "$pkg" 2>/dev/null && fw="${fw}Remix, "
  grep -qi '"hono"'     "$pkg" 2>/dev/null && fw="${fw}Hono, "
  grep -qi '"astro"'    "$pkg" 2>/dev/null && fw="${fw}Astro, "
  grep -qi '"solid-js"' "$pkg" 2>/dev/null && fw="${fw}SolidJS, "
  echo "${fw%, }"
}

detect_framework_python() {
  [[ -f "${PROJECT_ROOT}/requirements.txt" || -f "${PROJECT_ROOT}/pyproject.toml" ]] || return 0
  local fw=""
  grep -qi "django"  "${PROJECT_ROOT}/requirements.txt" "${PROJECT_ROOT}/pyproject.toml" 2>/dev/null && fw="${fw}Django, "
  grep -qi "flask"   "${PROJECT_ROOT}/requirements.txt" "${PROJECT_ROOT}/pyproject.toml" 2>/dev/null && fw="${fw}Flask, "
  grep -qi "fastapi" "${PROJECT_ROOT}/requirements.txt" "${PROJECT_ROOT}/pyproject.toml" 2>/dev/null && fw="${fw}FastAPI, "
  grep -qi "djangorestframework" "${PROJECT_ROOT}/requirements.txt" "${PROJECT_ROOT}/pyproject.toml" 2>/dev/null && fw="${fw}Django REST Framework, "
  echo "${fw%, }"
}

detect_framework_go() {
  [[ -f "${PROJECT_ROOT}/go.mod" ]] || return 0
  local fw=""
  grep -qi "gin-gonic" "${PROJECT_ROOT}/go.mod" 2>/dev/null && fw="${fw}Gin, "
  grep -qi "gofiber"   "${PROJECT_ROOT}/go.mod" 2>/dev/null && fw="${fw}Fiber, "
  grep -qi "labstack/echo" "${PROJECT_ROOT}/go.mod" 2>/dev/null && fw="${fw}Echo, "
  echo "${fw%, }"
}

detect_framework_rust() {
  [[ -f "${PROJECT_ROOT}/Cargo.toml" ]] || return 0
  local fw=""
  grep -qi "actix" "${PROJECT_ROOT}/Cargo.toml" 2>/dev/null && fw="${fw}Actix, "
  grep -qi "axum"  "${PROJECT_ROOT}/Cargo.toml" 2>/dev/null && fw="${fw}Axum, "
  grep -qi "rocket" "${PROJECT_ROOT}/Cargo.toml" 2>/dev/null && fw="${fw}Rocket, "
  echo "${fw%, }"
}

detect_framework_elixir() {
  [[ -f "${PROJECT_ROOT}/mix.exs" ]] || return 0
  local fw=""
  grep -qi "phoenix" "${PROJECT_ROOT}/mix.exs" 2>/dev/null && fw="${fw}Phoenix, "
  grep -qi "phoenix_live_view" "${PROJECT_ROOT}/mix.exs" 2>/dev/null && fw="${fw}LiveView, "
  echo "${fw%, }"
}

detect_framework_php() {
  [[ -f "${PROJECT_ROOT}/composer.json" ]] || return 0
  local fw=""
  grep -qi "laravel" "${PROJECT_ROOT}/composer.json" 2>/dev/null && fw="${fw}Laravel, "
  grep -qi "symfony" "${PROJECT_ROOT}/composer.json" 2>/dev/null && fw="${fw}Symfony, "
  echo "${fw%, }"
}

detect_framework_java() {
  [[ -f "${PROJECT_ROOT}/pom.xml" || -f "${PROJECT_ROOT}/build.gradle" || -f "${PROJECT_ROOT}/build.gradle.kts" ]] || return 0
  local fw=""
  grep -qi "spring-boot" "${PROJECT_ROOT}/pom.xml" "${PROJECT_ROOT}/build.gradle" "${PROJECT_ROOT}/build.gradle.kts" 2>/dev/null && fw="${fw}Spring Boot, "
  echo "${fw%, }"
}

register_detector "framework" "ruby"    "detect_framework_ruby"
register_detector "framework" "node"    "detect_framework_node"
register_detector "framework" "python"  "detect_framework_python"
register_detector "framework" "go"      "detect_framework_go"
register_detector "framework" "rust"    "detect_framework_rust"
register_detector "framework" "elixir"  "detect_framework_elixir"
register_detector "framework" "php"     "detect_framework_php"
register_detector "framework" "java"    "detect_framework_java"
