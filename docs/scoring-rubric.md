# Scoring Rubric

`claude-maxout` scores your Claude ecosystem across 5 layers, totalling 100 points.

## Grade scale

| Score | Grade | Meaning |
|-------|-------|---------|
| 90–100 | A | Fully optimised — you're getting maximum value from Claude Code |
| 75–89 | B | Strong setup — a few gaps worth filling |
| 60–74 | C | Decent baseline — several high-impact improvements available |
| 45–59 | D | Basic setup — significant upside from ecosystem investment |
| 0–44 | F | Just getting started — lots of quick wins available |

---

## Layer 1: Claude Core (max 30 pts)

Your global `~/.claude/` configuration — the foundation of every Claude Code session.

| Check | Points | Why it matters |
|-------|--------|----------------|
| `~/.claude/CLAUDE.md` exists | 5 | Without this, Claude has no persistent context about how you work |
| CLAUDE.md has >200 words | 5 | A few lines isn't enough — Claude needs real context about your preferences |
| CLAUDE.md has ≥5 sections | 5 | Structure matters; sections like "Operating Principles" and "Verification Protocol" directly shape behaviour |
| `~/.claude/settings.json` exists | 5 | Without this, Claude prompts you for every tool permission |
| settings.json has ≥3 permission rules | 5 | Fewer prompts = faster iteration; pre-allow the tools you use constantly |
| settings.json has a hooks block | 5 | Hooks automate safety checks and notifications — they're what separates a passive Claude from an active one |

---

## Layer 2: Project Config (max 20 pts)

Per-project `.claude/` config — tells Claude what's specific to this codebase.

| Check | Points | Why it matters |
|-------|--------|----------------|
| `.claude/` directory exists | 5 | Opt-in to project-level context |
| `.claude/CLAUDE.md` exists | 5 | Project-specific rules: commands, file layout, constraints Claude must know |
| `.claude/settings.json` exists | 5 | Project-scoped permissions (e.g. allow `npm run *` only in this project) |
| `.omc/` or workflow dir present | 5 | Signals advanced orchestration (oh-my-claudecode, custom workflows) |

---

## Layer 3: MCP Coverage (max 20 pts)

MCP servers extend what Claude can do. 4 points per category covered.

| Category | Points | Example servers |
|----------|--------|-----------------|
| Docs | 4 | context7, devdocs — real-time framework docs so Claude doesn't hallucinate stale APIs |
| Browser | 4 | playwright, puppeteer — Claude can interact with your actual UI |
| Filesystem/Storage | 4 | filesystem, google-drive — access beyond the project root |
| Code intelligence | 4 | ast-grep, LSP servers — structural code search |
| External services | 4 | GitHub, Linear, Slack — Claude can act on your tools directly |

---

## Layer 4: Stack Fit (max 15 pts)

Does your Claude setup match what you're actually building? Up to 3 pts per gap found.

| Gap | Points | Fix |
|-----|--------|-----|
| Next.js with no docs MCP | 3 | Add context7 — Next.js API surface changes fast |
| React with no browser MCP | 3 | Add Playwright — Claude can't test your UI without it |
| Python project, no Python context in CLAUDE.md | 3 | Use the python-api.md template |
| Docker project, no container context in CLAUDE.md | 3 | Add your service topology to .claude/CLAUDE.md |
| Node project, no project CLAUDE.md | 3 | Use the node-fullstack.md template |

---

## Layer 5: Shell Ecosystem (max 15 pts)

The developer environment that hosts Claude Code.

| Check | Points | Why it matters |
|-------|--------|----------------|
| tmux installed and active | 3 | Persistent sessions — Claude keeps running if your terminal closes |
| `~/.tmux.conf` has real config | 3 | Signals a configured, intentional setup |
| Ghostty terminal | 3 | GPU rendering = no lag on long Claude outputs |
| git has useful aliases | 3 | Claude can use shorter, idiomatic git commands |
| Claude Code CLI in PATH | 3 | Basic prerequisite — flagged if missing |
