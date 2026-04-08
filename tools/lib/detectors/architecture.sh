#!/usr/bin/env bash
# lib/detectors/architecture.sh — Architecture Pattern Detectors
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

detect_arch_mvc() {
  [[ -d "${PROJECT_ROOT}/app/models" && -d "${PROJECT_ROOT}/app/controllers" ]] && echo "MVC"
}

detect_arch_service_layer() {
  [[ -d "${PROJECT_ROOT}/app/services" || -d "${PROJECT_ROOT}/src/services" ]] && echo "Service Layer"
}

detect_arch_background_jobs() {
  [[ -d "${PROJECT_ROOT}/app/jobs" || -d "${PROJECT_ROOT}/app/workers" ]] && echo "Background Jobs"
}

detect_arch_policy_objects() {
  [[ -d "${PROJECT_ROOT}/app/policies" ]] && echo "Policy Objects"
}

detect_arch_repository() {
  [[ -d "${PROJECT_ROOT}/src/repositories" || -d "${PROJECT_ROOT}/src/repo" ]] && echo "Repository Pattern"
}

detect_arch_middleware() {
  [[ -d "${PROJECT_ROOT}/src/middleware" ]] && echo "Middleware"
}

detect_arch_dto() {
  [[ -d "${PROJECT_ROOT}/src/dto" || -d "${PROJECT_ROOT}/src/schemas" ]] && echo "DTOs/Schemas"
}

detect_arch_domain() {
  [[ -d "${PROJECT_ROOT}/src/domain" || -d "${PROJECT_ROOT}/src/entities" ]] && echo "Domain Entities"
}

detect_arch_event_driven() {
  [[ -d "${PROJECT_ROOT}/src/events" || -d "${PROJECT_ROOT}/app/events" ]] && echo "Event-Driven"
}

detect_arch_hexagonal() {
  [[ -d "${PROJECT_ROOT}/src/ports" || -d "${PROJECT_ROOT}/src/adapters" ]] && echo "Hexagonal (Ports & Adapters)"
}

detect_arch_cqrs() {
  [[ -d "${PROJECT_ROOT}/src/commands" && -d "${PROJECT_ROOT}/src/queries" ]] && echo "CQRS"
}

register_detector "architecture" "mvc"             "detect_arch_mvc"
register_detector "architecture" "service_layer"   "detect_arch_service_layer"
register_detector "architecture" "background_jobs" "detect_arch_background_jobs"
register_detector "architecture" "policy_objects"  "detect_arch_policy_objects"
register_detector "architecture" "repository"      "detect_arch_repository"
register_detector "architecture" "middleware"       "detect_arch_middleware"
register_detector "architecture" "dto"             "detect_arch_dto"
register_detector "architecture" "domain"          "detect_arch_domain"
register_detector "architecture" "event_driven"    "detect_arch_event_driven"
register_detector "architecture" "hexagonal"       "detect_arch_hexagonal"
register_detector "architecture" "cqrs"            "detect_arch_cqrs"
