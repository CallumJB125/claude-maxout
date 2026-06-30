# claude-maxout

> Find out how well you're using Claude Code — and fix the gaps.

Claude Code has a rich ecosystem: CLAUDE.md for persistent context, settings.json for permissions and hooks, MCP servers that extend what Claude can do, tmux for persistent sessions, and stack-specific configuration. Most people use maybe 20% of it.

**claude-maxout** audits your entire setup in 30 seconds and tells you exactly what's missing — with copy-paste commands to fix it.

---

## Quick start

```bash
git clone https://github.com/YOUR_USERNAME/claude-maxout.git
cd claude-maxout
./audit.sh
```

Or run directly without cloning:
```bash
bash <(curl -s https://raw.githubusercontent.com/CallumJB125/claude-maxout/main/audit.sh)
```

---

## What it audits

| Layer | Max | What it checks |
|-------|-----|----------------|
| **Claude Core** | 30 | `~/.claude/CLAUDE.md` quality, settings.json, hooks |
| **Project Config** | 20 | `.claude/` per-project setup |
| **MCP Coverage** | 20 | Which MCP servers you have vs. what your stack needs |
| **Stack Fit** | 15 | Detects your framework, flags missing config for it |
| **Shell Ecosystem** | 15 | tmux, Ghostty, git aliases, Claude Code version |

### Sample output

```
╔══════════════════════════════════════════╗
║        claude-maxout audit v1.0          ║
╚══════════════════════════════════════════╝

Stack detected: Next.js Node React Docker

SCORE: 61/100  ████████████░░░░░░░░  Grade: B

Layer 1  Claude Core            22/30  ██████████████░░░░░░
Layer 2  Project Config          8/20  ████░░░░░░░░░░░░░░░░
Layer 3  MCP Coverage           12/20  ████████████░░░░░░░░
Layer 4  Stack Fit              11/15  ██████████████░░░░░░
Layer 5  Shell Ecosystem         8/15  ██████████░░░░░░░░░░

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOP FIXES  (sorted by impact)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[+5 pts] Add hooks to ~/.claude/settings.json
  → cp templates/settings/settings-advanced.json ~/.claude/settings.json

[+5 pts] Create a project-level .claude/CLAUDE.md
  → cp templates/CLAUDE.md/node-fullstack.md .claude/CLAUDE.md

[+4 pts] Add context7 MCP for real-time Next.js docs
  → See templates/mcp/context7.json
```

---

## Flags

```bash
./audit.sh             # Standard audit of current directory
./audit.sh --verbose   # Show PASS/FAIL for every individual check
./audit.sh --json      # Machine-readable JSON output (pipe to jq)
```

---

## Templates

The `templates/` directory has ready-to-use configs you can copy directly:

| Template | What it is |
|----------|-----------|
| `templates/CLAUDE.md/base.md` | Universal CLAUDE.md starting point |
| `templates/CLAUDE.md/node-fullstack.md` | Node + React/Express specific |
| `templates/CLAUDE.md/python-api.md` | Python + FastAPI/Django specific |
| `templates/CLAUDE.md/go-service.md` | Go service specific |
| `templates/CLAUDE.md/monorepo.md` | Monorepo (npm/pnpm workspaces) |
| `templates/settings/settings-base.json` | Minimal settings.json with common permissions |
| `templates/settings/settings-advanced.json` | Full settings with hooks + MCP stub |
| `templates/hooks/pre-tool-bash.sh` | Safety hook (blocks dangerous commands) |
| `templates/hooks/post-tool-notify.sh` | macOS notification when long tasks finish |
| `templates/mcp/context7.json` | context7 MCP snippet |
| `templates/mcp/playwright.json` | Playwright MCP snippet |
| `templates/mcp/filesystem.json` | Filesystem MCP snippet |

---

## Docs

- [MCP Server Catalog](docs/mcp-catalog.md) — 15+ servers, what each does, when to use it
- [tmux Guide](docs/tmux-guide.md) — minimal config + essential commands for Claude Code sessions
- [Ghostty Guide](docs/ghostty-guide.md) — recommended terminal config
- [Scoring Rubric](docs/scoring-rubric.md) — full explanation of how each layer is scored

---

## Requirements

- bash 4+ (macOS ships bash 3; `brew install bash` for full compatibility, or use zsh)
- `jq` (optional — improves MCP detection accuracy): `brew install jq`
- Claude Code CLI: `npm install -g @anthropic-ai/claude-code`

---

## Contributing

1. Fork and clone
2. Add a check to the appropriate `lib/audit-*.sh`
3. Update `docs/scoring-rubric.md` with the new check and its point value
4. Run `shellcheck audit.sh lib/*.sh` — zero errors required
5. Open a PR

See [CLAUDE.md](CLAUDE.md) for project conventions.

---

## Why this exists

The Claude Code ecosystem is genuinely powerful — but it's scattered across docs, GitHub repos, and Discord servers. Most users have a half-configured setup and don't know what they're missing. This tool does the survey for you, in your actual environment, against your actual stack.
