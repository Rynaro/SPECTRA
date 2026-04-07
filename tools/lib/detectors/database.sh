#!/usr/bin/env bash
# lib/detectors/database.sh — Database & ORM Detectors
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

detect_db_rails_config() {
  [[ -f "${PROJECT_ROOT}/config/database.yml" ]] || return 0
  local db=""
  grep -qi "postgres" "${PROJECT_ROOT}/config/database.yml" 2>/dev/null && db="${db}PostgreSQL, "
  grep -qi "mysql"    "${PROJECT_ROOT}/config/database.yml" 2>/dev/null && db="${db}MySQL, "
  grep -qi "sqlite"   "${PROJECT_ROOT}/config/database.yml" 2>/dev/null && db="${db}SQLite, "
  echo "${db%, }"
}

detect_db_node() {
  [[ -f "${PROJECT_ROOT}/package.json" ]] || return 0
  local db="" pkg="${PROJECT_ROOT}/package.json"
  grep -qi '"prisma"'   "$pkg" 2>/dev/null && db="${db}Prisma, "
  grep -qi '"mongoose"' "$pkg" 2>/dev/null && db="${db}MongoDB, "
  grep -qi '"typeorm"'  "$pkg" 2>/dev/null && db="${db}TypeORM, "
  grep -qi '"drizzle"'  "$pkg" 2>/dev/null && db="${db}Drizzle, "
  grep -qi '"sequelize"' "$pkg" 2>/dev/null && db="${db}Sequelize, "
  echo "${db%, }"
}

detect_db_redis() {
  grep -rql "redis" \
    "${PROJECT_ROOT}/Gemfile" \
    "${PROJECT_ROOT}/package.json" \
    "${PROJECT_ROOT}/requirements.txt" \
    "${PROJECT_ROOT}/pyproject.toml" \
    2>/dev/null | head -1 | grep -q . && echo "Redis"
}

register_detector "database" "rails_config" "detect_db_rails_config"
register_detector "database" "node"         "detect_db_node"
register_detector "database" "redis"        "detect_db_redis"
