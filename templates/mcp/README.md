# MCP Templates

Each file here is a ready-to-merge snippet for `~/.claude/settings.json` or `.claude/settings.json`.

## How to use

1. Open your target settings file
2. Find (or add) the `"mcpServers"` key
3. Copy the inner object from the template and merge it in

Example — adding context7 to an existing settings.json:
```json
{
  "permissions": { ... },
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

## Available templates

| File | Server | Best for |
|---|---|---|
| `context7.json` | context7 | Real-time framework docs (Next.js, React, etc.) |
| `playwright.json` | Playwright | Browser automation, UI testing |
| `filesystem.json` | Filesystem | Access files outside the project root |

## More servers

See `docs/mcp-catalog.md` for the full curated catalog with 10+ servers.
