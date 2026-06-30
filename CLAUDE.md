# claude-maxout

A shell-script audit tool and template library for Claude Code ecosystems.

## Project Overview

This repo:
1. Audits a developer's Claude Code setup across 5 layers (core config, project config, MCP servers, stack fit, shell environment)
2. Outputs a scored report with actionable fix commands
3. Ships ready-to-use templates for CLAUDE.md, settings.json, hooks, and MCP configs

## Commands

```bash
./audit.sh           # Run the full audit
./audit.sh --verbose # Show pass/fail for every check
./audit.sh --json    # Machine-readable output
./audit.sh --fix     # Auto-apply safe fixes (future feature)
shellcheck audit.sh lib/*.sh   # Lint all shell scripts
```

## Project Structure

```
audit.sh              # Entry point — sources lib/ modules
lib/
  detect-stack.sh     # Language/framework detection
  audit-claude-core.sh  # Layer 1: ~/.claude/ audit
  audit-project.sh    # Layer 2: ./.claude/ audit
  audit-mcp.sh        # Layer 3: MCP server coverage
  audit-stack.sh      # Layer 4: Stack-specific gaps
  audit-env.sh        # Layer 5: Shell ecosystem
  report.sh           # Score engine + terminal output
templates/            # Ready-to-use config templates
docs/                 # Guides and scoring rubric
```

## Conventions

- All shell scripts: `#!/usr/bin/env bash` + `set -euo pipefail`
- Each `audit-*.sh` exports two functions: `audit_<name>()` (returns score) and `get_fixes_<name>()` (returns fix strings)
- Fix strings format: `"<pts>|<description>|<command>"` — pipe-delimited, no literal pipes in values
- All scripts must pass `shellcheck` with zero errors
- Templates are minimal and well-commented — they are the product, not just examples

## Adding a new check

1. Add a check inside the appropriate `lib/audit-*.sh`
2. If it finds a gap, push to the layer's `_*_FIXES` array in format `"pts|desc|cmd"`
3. Update `docs/scoring-rubric.md` with the new check
4. Test by running `./audit.sh --verbose`

## Adding a new template

1. Add the file to the appropriate `templates/` subdirectory
2. Add an entry to `docs/mcp-catalog.md` (for MCP templates) or update `README.md`
