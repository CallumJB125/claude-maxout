#!/usr/bin/env bash
# Layer 3: MCP server coverage audit (max 20 pts)
# 4 pts per category: docs, browser, filesystem, code-intel, AI

_MCP_FIXES=()

_get_mcp_servers() {
  local servers=""
  # Read from global settings
  if [[ -f "$HOME/.claude/settings.json" ]] && command -v jq &>/dev/null; then
    servers+=$(jq -r '.mcpServers // {} | keys[]' "$HOME/.claude/settings.json" 2>/dev/null || true)
    servers+=" "
  fi
  # Read from project settings
  local proj_settings="${PROJECT_DIR:-$(pwd)}/.claude/settings.json"
  if [[ -f "$proj_settings" ]] && command -v jq &>/dev/null; then
    servers+=$(jq -r '.mcpServers // {} | keys[]' "$proj_settings" 2>/dev/null || true)
  fi
  # Fallback: grep for mcpServers keys
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

  # Category: docs (context7, devdocs, etc.)
  if echo "$servers" | grep -qiE "context7|devdocs|docs"; then
    score=$((score + 4))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Docs MCP server configured (context7/devdocs)"
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] No docs MCP server (context7 recommended)"
    _MCP_FIXES+=("4|Add context7 MCP for real-time framework docs|See templates/mcp/context7.json")
  fi

  # Category: browser (playwright, puppeteer, etc.)
  if echo "$servers" | grep -qiE "playwright|puppeteer|browser|selenium"; then
    score=$((score + 4))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Browser automation MCP configured"
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] No browser automation MCP (playwright recommended)"
    _MCP_FIXES+=("4|Add Playwright MCP for browser automation in Claude|See templates/mcp/playwright.json")
  fi

  # Category: filesystem (beyond built-in)
  if echo "$servers" | grep -qiE "filesystem|file-system|fs|drive|s3|storage"; then
    score=$((score + 4))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Filesystem/storage MCP configured"
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] No filesystem MCP beyond built-in"
    _MCP_FIXES+=("4|Add filesystem MCP for broader file access|See templates/mcp/filesystem.json")
  fi

  # Category: code intelligence (LSP, search, etc.)
  if echo "$servers" | grep -qiE "lsp|ast|ast-grep|ripgrep|sourcegraph|codesearch"; then
    score=$((score + 4))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Code intelligence MCP configured"
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] No code intelligence MCP"
    _MCP_FIXES+=("4|Add an LSP/code-search MCP for smarter code navigation|See docs/mcp-catalog.md")
  fi

  # Category: AI / external services (Slack, GitHub, Linear, etc.)
  if echo "$servers" | grep -qiE "github|gitlab|linear|slack|notion|jira|telegram"; then
    score=$((score + 4))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] External service MCP configured"
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] No external service MCP (GitHub, Slack, Linear, etc.)"
    _MCP_FIXES+=("4|Add a service integration MCP (GitHub, Linear, Slack)|See docs/mcp-catalog.md")
  fi

  echo "$score"
}

get_fixes_mcp() {
  printf '%s\n' "${_MCP_FIXES[@]:-}"
}
