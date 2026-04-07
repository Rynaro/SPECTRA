#!/usr/bin/env bash
# lib/detectors/languages.sh — Language Detectors
# Detects programming languages present in the project.
#
# SPECTRA v4.2.0 — https://github.com/Rynaro/SPECTRA
# License: CC BY-SA 4.0

detect_language_ruby() {
  [[ -f "${PROJECT_ROOT}/Gemfile" ]] && echo "Ruby"
}

detect_language_javascript() {
  [[ -f "${PROJECT_ROOT}/package.json" ]] && echo "JavaScript/TypeScript"
}

detect_language_python() {
  [[ -f "${PROJECT_ROOT}/requirements.txt" || \
     -f "${PROJECT_ROOT}/pyproject.toml" || \
     -f "${PROJECT_ROOT}/setup.py" || \
     -f "${PROJECT_ROOT}/Pipfile" ]] && echo "Python"
}

detect_language_go() {
  [[ -f "${PROJECT_ROOT}/go.mod" ]] && echo "Go"
}

detect_language_rust() {
  [[ -f "${PROJECT_ROOT}/Cargo.toml" ]] && echo "Rust"
}

detect_language_java_kotlin() {
  [[ -f "${PROJECT_ROOT}/pom.xml" || \
     -f "${PROJECT_ROOT}/build.gradle" || \
     -f "${PROJECT_ROOT}/build.gradle.kts" ]] && echo "Java/Kotlin"
}

detect_language_elixir() {
  [[ -f "${PROJECT_ROOT}/mix.exs" ]] && echo "Elixir"
}

detect_language_php() {
  [[ -f "${PROJECT_ROOT}/composer.json" ]] && echo "PHP"
}

detect_language_swift() {
  [[ -f "${PROJECT_ROOT}/Package.swift" ]] && echo "Swift"
}

detect_language_dart() {
  [[ -f "${PROJECT_ROOT}/pubspec.yaml" ]] && echo "Dart/Flutter"
}

detect_language_csharp() {
  find "${PROJECT_ROOT}" -maxdepth 1 \( -name "*.csproj" -o -name "*.sln" \) 2>/dev/null \
    | head -1 | grep -q . && echo "C#/.NET"
}

detect_language_zig() {
  [[ -f "${PROJECT_ROOT}/build.zig" ]] && echo "Zig"
}

detect_language_scala() {
  [[ -f "${PROJECT_ROOT}/build.sbt" ]] && echo "Scala"
}

detect_language_haskell() {
  [[ -f "${PROJECT_ROOT}/stack.yaml" ]] || \
    find "${PROJECT_ROOT}" -maxdepth 1 -name "*.cabal" 2>/dev/null | grep -q . && echo "Haskell"
}

# Fallback: extension-based detection for languages with no manifest
detect_language_by_extension() {
  # Only run if no manifest-based language was detected
  local any_detected=0
  local lang
  for lang in ruby javascript python go rust java_kotlin elixir php swift dart csharp zig scala haskell; do
    "detect_language_${lang}" 2>/dev/null | grep -q . && { any_detected=1; break; }
  done
  [[ $any_detected -eq 1 ]] && return 0

  find "${PROJECT_ROOT}" -maxdepth 4 -type f \
    \( -name "*.rb" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \
       -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.kt" \
       -o -name "*.cs" -o -name "*.ex" -o -name "*.php" -o -name "*.swift" \) \
    2>/dev/null \
    | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -3 | awk '{print $2}' \
    | tr '\n' ', ' | sed 's/, $//'
}

register_detector "language" "ruby"             "detect_language_ruby"
register_detector "language" "javascript"       "detect_language_javascript"
register_detector "language" "python"           "detect_language_python"
register_detector "language" "go"               "detect_language_go"
register_detector "language" "rust"             "detect_language_rust"
register_detector "language" "java_kotlin"      "detect_language_java_kotlin"
register_detector "language" "elixir"           "detect_language_elixir"
register_detector "language" "php"              "detect_language_php"
register_detector "language" "swift"            "detect_language_swift"
register_detector "language" "dart"             "detect_language_dart"
register_detector "language" "csharp"           "detect_language_csharp"
register_detector "language" "zig"              "detect_language_zig"
register_detector "language" "scala"            "detect_language_scala"
register_detector "language" "haskell"          "detect_language_haskell"
register_detector "language" "by_extension"     "detect_language_by_extension"
