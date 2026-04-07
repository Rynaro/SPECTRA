# Project Detectors

Each `.sh` file in this directory registers one or more project detectors.
Detectors are auto-sourced by the module loader — no changes to the entry point needed.

## Interface Contract

Each detector is a shell function that:
- Takes no arguments
- Echoes detected values as a comma-separated string (e.g., `"Ruby, JavaScript"`)
- Echoes nothing (empty string) if nothing is detected
- Must call `register_detector` to register itself

```bash
detect_<name>() {
  local result=""
  [[ -f "some-file" ]] && result="${result}SomeTech, "
  echo "${result%, }"
}

register_detector "<category>" "<name>" "detect_<name>"
```

## Categories

| Category | Description |
|----------|-------------|
| `language` | Programming languages (Ruby, Go, Python...) |
| `framework` | Web/app frameworks (Rails, Next.js, Django...) |
| `test` | Test frameworks (RSpec, Jest, pytest...) |
| `build` | Build tools and package managers (Make, npm, Cargo...) |
| `ci` | CI/CD systems (GitHub Actions, GitLab CI...) |
| `database` | Databases and ORMs (PostgreSQL, Prisma...) |
| `architecture` | Structural patterns (MVC, Service Layer...) |
| `conventions` | Existing LLM/doc convention files |

## Adding a New Detector

1. Create a new `.sh` file (or add to an existing one for related detections)
2. Define your function following the interface contract above
3. Call `register_detector` at the bottom of the function definition
4. The module loader picks it up automatically on next run
