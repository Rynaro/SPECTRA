# SPECTRA Installer

Interactive, self-contained installer that places SPECTRA methodology files into your project in the correct location for your LLM tool.

## Usage

```bash
# From your project root
bash /path/to/SPECTRA/tools/spectra-init.sh

# Or pass the target project path explicitly
bash /path/to/SPECTRA/tools/spectra-init.sh /path/to/your/project
```

The installer will:
1. Analyze your project's tech stack
2. Auto-detect your LLM tool (Claude Code, GitHub Copilot, Cursor)
3. Ask whether you want Agent mode or Skill mode
4. Show you exactly what will be installed
5. Place all files and generate your adaptation prompt

## Non-Interactive Mode

For CI, scripts, or automation:

```bash
SPECTRA_VENDOR=claude \
SPECTRA_MODE=skill \
SPECTRA_YES=1 \
bash tools/spectra-init.sh /path/to/project
```

| Variable | Values | Description |
|----------|--------|-------------|
| `SPECTRA_VENDOR` | `claude`, `copilot`, `cursor` | Skip vendor detection |
| `SPECTRA_MODE` | `agent`, `skill` | Skip mode selection |
| `SPECTRA_YES` | `1` | Auto-confirm all prompts |
| `NO_COLOR` | `1` | Disable ANSI colors |

## What Gets Installed

### Always (every install)

```
.spectra/
├── plans/                          # Your planning artifacts go here
└── setup/
    ├── project-profile.md          # Detected stack summary
    ├── adaptation-prompt.md        # Paste into any LLM
    └── spectra-conventions.md      # Stub — fill after running prompt
```

### Vendor + Mode specific

| Vendor | Agent mode | Skill mode |
|--------|-----------|------------|
| Claude Code | `.claude/agents/spectra-planner.md` | `.claude/skills/spectra-methodology/` |
| GitHub Copilot | `.github/agents/spectra-planner.agent.md` | `.github/skills/spectra-methodology/` |
| Cursor | `.cursor/agents/spectra-planner.mdc` | `.cursor/rules/spectra-methodology.mdc` |

## Architecture

The installer is modular — each concern lives in its own file:

```
tools/
├── spectra-init.sh              # Entry point (~45 lines)
├── lib/
│   ├── core.sh                  # Constants, colors, utilities, module loader
│   ├── config.sh                # Output paths and env-var defaults
│   ├── tui.sh                   # TUI rendering (pure bash ANSI)
│   ├── errors.sh                # Trap handlers and rollback
│   ├── vendor_registry.sh       # Vendor registration and dispatch
│   ├── detector_registry.sh     # Detector registration and dispatch
│   ├── installer.sh             # File placement engine
│   ├── vendors/                 # One file per supported LLM tool
│   │   ├── claude.sh
│   │   ├── copilot.sh
│   │   └── cursor.sh
│   ├── detectors/               # One file per detection category
│   │   ├── languages.sh
│   │   ├── frameworks.sh
│   │   ├── testing.sh
│   │   ├── build.sh
│   │   ├── ci.sh
│   │   ├── database.sh
│   │   ├── architecture.sh
│   │   └── conventions.sh
│   └── flows/                   # User journey orchestration
│       ├── main_flow.sh
│       ├── vendor_flow.sh
│       ├── mode_flow.sh
│       └── summary_flow.sh
└── assets/
    ├── methodology/             # Copies of SPECTRA methodology files
    └── templates/               # Parameterized templates
```

## Adding a New Vendor

1. Create `tools/lib/vendors/<vendorname>.sh`
2. Implement three functions:
   ```bash
   vendor_<name>_detect()    # exit 0 if vendor is present
   vendor_<name>_describe()  # print one-line description
   vendor_<name>_install()   # place files; receives mode ("agent"|"skill")
   ```
3. Call `register_vendor` at the bottom
4. That's it — the module loader picks it up automatically

See `tools/lib/vendors/README.md` for the full contract and a template.

## Adding a New Detector

1. Create `tools/lib/detectors/<category>.sh` (or add to an existing one)
2. Implement a detection function:
   ```bash
   detect_<name>() {
     [[ -f "some-indicator-file" ]] && echo "TechName"
   }
   register_detector "<category>" "<name>" "detect_<name>"
   ```
3. Categories: `language`, `framework`, `test`, `build`, `ci`, `database`, `architecture`, `conventions`

See `tools/lib/detectors/README.md` for the full contract.

## Requirements

- bash 4.0+ (macOS ships bash 3.x; upgrade with `brew install bash`)
- Standard coreutils: `find`, `grep`, `wc`, `sort`, `head`, `cp`, `mkdir`
- No external dependencies
