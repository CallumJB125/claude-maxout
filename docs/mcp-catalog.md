# MCP Server Catalog

A curated list of MCP servers for Claude Code users. Add these to `~/.claude/settings.json` under `mcpServers`.

## How to add any server

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@package/name@latest"]
    }
  }
}
```

---

## Documentation

| Server | Install | Best for |
|--------|---------|----------|
| **context7** | `npx -y @upstash/context7-mcp@latest` | Real-time docs for Next.js, React, Tailwind, Prisma, etc. — Claude won't hallucinate stale APIs |
| **devdocs** | `npx -y @modelcontextprotocol/server-devdocs` | Offline-first dev documentation search |

## Browser Automation

| Server | Install | Best for |
|--------|---------|----------|
| **playwright** | `npx -y @playwright/mcp@latest` | Let Claude navigate, click, screenshot, and test web UIs |
| **puppeteer** | `npx -y @modelcontextprotocol/server-puppeteer` | Headless Chrome automation, PDF generation |

## Filesystem & Storage

| Server | Install | Best for |
|--------|---------|----------|
| **filesystem** | `npx -y @modelcontextprotocol/server-filesystem <paths>` | Give Claude read/write to directories outside the project |
| **google-drive** | `npx -y @modelcontextprotocol/server-gdrive` | Read/write Google Drive files from Claude |
| **s3** | `npx -y @modelcontextprotocol/server-aws-kb-retrieval` | Query S3 knowledge bases |

## Version Control & Project Management

| Server | Install | Best for |
|--------|---------|----------|
| **github** | `npx -y @modelcontextprotocol/server-github` | Create PRs, read issues, search code — all from Claude |
| **gitlab** | `npx -y @modelcontextprotocol/server-gitlab` | GitLab equivalent |
| **linear** | `npx -y @linear/mcp-server` | Create and update Linear issues from Claude |
| **jira** | `npx -y @modelcontextprotocol/server-jira` | Query and update Jira tickets |

## Communication

| Server | Install | Best for |
|--------|---------|----------|
| **slack** | `npx -y @modelcontextprotocol/server-slack` | Read channels, send messages, search Slack |

## Databases

| Server | Install | Best for |
|--------|---------|----------|
| **postgres** | `npx -y @modelcontextprotocol/server-postgres <conn-string>` | Query PostgreSQL directly from Claude |
| **sqlite** | `npx -y @modelcontextprotocol/server-sqlite <db-path>` | Query SQLite databases |

## Code Intelligence

| Server | Install | Best for |
|--------|---------|----------|
| **ast-grep** | `npx -y @ast-grep/mcp` | Structural code search and replace across large codebases |

## AI & Search

| Server | Install | Best for |
|--------|---------|----------|
| **brave-search** | `npx -y @modelcontextprotocol/server-brave-search` | Web search without leaving Claude |
| **fetch** | `npx -y @modelcontextprotocol/server-fetch` | Fetch any URL and convert to markdown |

---

## Stack-to-MCP cheat sheet

| If you're building... | Add these MCPs |
|----------------------|----------------|
| Next.js / React app  | context7, playwright |
| Python API           | context7, postgres/sqlite |
| Go service           | filesystem, github |
| Any fullstack app    | context7, playwright, github |
| Data pipeline        | filesystem, postgres, fetch |
| Internal tool        | slack, linear, filesystem |
