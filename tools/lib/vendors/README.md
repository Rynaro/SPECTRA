# Vendor Adapters

Each `.sh` file in this directory is a vendor adapter for one LLM tool.
Adapters are auto-sourced by the module loader — no changes to the entry point needed.

## Interface Contract

Every adapter must define three functions and call `register_vendor`:

```bash
# Detection: exit 0 if this vendor is present in the project, 1 otherwise
vendor_<name>_detect() { ... }

# Description: print one line describing this vendor for the TUI menu
vendor_<name>_describe() { echo "Claude Code (.claude/)"; }

# Installation: receive mode ("agent" or "skill"), place files accordingly
vendor_<name>_install() {
  local mode="$1"
  case "$mode" in
    agent) ... ;;
    skill) ... ;;
  esac
}

# Registration (call at the bottom of the file, outside any function)
register_vendor "<name>" "vendor_<name>_detect" "vendor_<name>_install" "vendor_<name>_describe"
```

## Adding a New Vendor

1. Copy an existing adapter as a template: `cp claude.sh myvendor.sh`
2. Replace all occurrences of the old name with your vendor name
3. Update `_detect` to check for your vendor's configuration files/directories
4. Update `_install` to place files in your vendor's expected locations
5. Update `_describe` to return a human-readable label
6. That's it — the module loader picks it up automatically

## Naming Convention

- File: `<vendorname>.sh` (lowercase, no hyphens)
- Functions: `vendor_<vendorname>_detect`, `vendor_<vendorname>_install`, `vendor_<vendorname>_describe`
- Registration name: `<vendorname>` (must match file base name)
