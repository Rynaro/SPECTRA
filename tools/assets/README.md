# tools/assets

Installer assets for SPECTRA. Organized into two subdirectories:

## methodology/

Copies of the core SPECTRA methodology files, kept in sync with `docs/spectra-methodology/`.
These are the files physically installed into the user's project.

| File | Purpose |
|------|---------|
| `SPECTRA.md` | Full methodology reference |
| `SKILL.md` | Quick-reference card (skill mode) |
| `scoring.md` | Complexity rubrics and scoring tables |
| `templates.md` | Output format templates |

**Keep in sync:** If you update `docs/spectra-methodology/`, update these copies too.
Run `bash tools/scripts/sync-assets.sh` (once created) to automate this.

## templates/

Parameterized templates used by the installer to generate project-specific files.
Placeholders use `{{VARIABLE_NAME}}` syntax and are replaced at install time.

| File | Generated As | Variables Used |
|------|-------------|----------------|
| `conventions-stub.md` | `.spectra/setup/spectra-conventions.md` | PROJECT_NAME, SPECTRA_VERSION, DATE, SPECTRA_REPO, PROJECT_ROOT |
| `agent-planner.md.tmpl` | Vendor-specific agent file | SPECTRA_METHODOLOGY_CONTENT |

## Adding a new methodology file

1. Add the source file to `docs/spectra-methodology/`
2. Copy it to `tools/assets/methodology/`
3. Update `tools/lib/installer.sh` to reference it in the relevant vendor adapters
