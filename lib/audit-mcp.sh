#!/usr/bin/env bash
# Layer 3: MCP server coverage audit (max 20 pts)

_add_fix_mcp() {
  echo "$1" >> "$AUDIT_TMP/fixes_mcp.txt"
}

_get_mcp_servers() {
  local servers=""
  if [[ -f "$HOME/.claude/settings.json" ]] && command -v jq &>/dev/null; then
    servers+=$(jq -r '.mcpServers // {} | keys[]' "$HOME/.claude/settings.json" 2>/dev/null || true)
    servers+=" "
  fi
  local proj_settings="${PROJECT_DIR:-$(pwd)}/.claude/settings.json"
  if [[ -f "$proj_settings" ]] && command -v jq &>/dev/null; then
    servers+=$(jq -r '.mcpServers // {} | keys[]' "$proj_settings" 2>/dev/null || true)
  fi
  if [[ -z "$(echo "$servers" | tr -d '[:space:]')" ]]; then
    for f in "$HOME/.claude/settings.json" "${PROJECT_DIR:-$(pwd)}/.claude/settings.json"; do
      [[ -f "$f" ]] && servers+=$(grep -oE '"[a-z0-9_-]+"' "$f" 2>/dev/null | tr -d '"' | tr '\n' ' ')
    done
  fi
  echo "$servers"
}

audit_mcp() {
  local score=0
  local servers
  servers=$(_get_mcp_servers)

  if echo "$servers" | grep -qiE "context7|devdocs|docs"; then
    score=$((score + 4))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Docs MCP server configured (context7/devdocs)" >&2
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] No docs MCP server (context7 recommended)" >&2
    _add_fix_mcp "4|Add context7 MCP for real-time framework docs|See templates/mcp/context7.json"
  fi

  if echo "$servers" | grep -qiE "playwright|puppeteer|browser|selenium"; then
    score=$((score + 4))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Browser automation MCP configured" >&2
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] No browser automation MCP (playwright recommended)" >&2
    _add_fix_mcp "4|Add Playwright MCP for browser automation in Claude|See templates/mcp/playwright.json"
  fi

  if echo "$servers" | grep -qiE "filesystem|file-system|fs|drive|s3|storage"; then
    score=$((score + 4))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Filesystem/storage MCP configured" >&2
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] No filesystem MCP beyond built-in" >&2
    _add_fix_mcp "4|Add filesystem MCP for broader file access|See templates/mcp/filesystem.json"
  fi

  if echo "$servers" | grep -qiE "lsp|ast|ast-grep|ripgrep|sourcegraph|codesearch"; then
    score=$((score + 4))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Code intelligence MCP configured" >&2
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] No code intelligence MCP" >&2
    _add_fix_mcp "4|Add an LSP/code-search MCP for smarter code navigation|See docs/mcp-catalog.md"
  fi

  if echo "$servers" | grep -qiE "github|gitlab|linear|slack|notion|jira|telegram"; then
    score=$((score + 4))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] External service MCP configured" >&2
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] No external service MCP (GitHub, Slack, Linear, etc.)" >&2
    _add_fix_mcp "4|Add a service integration MCP (GitHub, Linear, Slack)|See docs/mcp-catalog.md"
  fi

  echo "$score"
}
