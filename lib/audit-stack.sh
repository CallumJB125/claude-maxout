#!/usr/bin/env bash
# Layer 4: Stack-specific gap analysis (max 15 pts)

_add_fix_stack() {
  echo "$1" >> "$AUDIT_TMP/fixes_stack.txt"
}

audit_stack() {
  local stacks="${1:-}"
  local score=0
  local dir="${PROJECT_DIR:-$(pwd)}"

  if [[ -z "$stacks" ]]; then
    [[ "$VERBOSE" == "true" ]] && echo "  [INFO] No stack detected in current directory — run from a project root" >&2
    echo "0"
    return
  fi

  [[ "$VERBOSE" == "true" ]] && echo "  [INFO] Auditing stack fit for: $stacks" >&2

  local servers
  servers=$(_get_mcp_servers 2>/dev/null || echo "")

  if echo "$stacks" | grep -q "Next.js"; then
    if echo "$servers" | grep -qiE "context7|devdocs"; then
      score=$((score + 3))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Next.js + docs MCP configured" >&2
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] Next.js detected but no docs MCP" >&2
      _add_fix_stack "3|You have Next.js but no docs MCP — Claude can't look up current Next.js APIs|Add context7: see templates/mcp/context7.json"
    fi
  fi

  if echo "$stacks" | grep -q "React"; then
    if echo "$servers" | grep -qiE "playwright|browser"; then
      score=$((score + 3))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] React + browser testing MCP configured" >&2
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] React detected but no browser automation MCP" >&2
      _add_fix_stack "3|React project with no browser MCP — Claude can't automate UI testing|Add Playwright MCP: see templates/mcp/playwright.json"
    fi
  fi

  if echo "$stacks" | grep -q "Python"; then
    local has_python_section=false
    if [[ -f "$dir/.claude/CLAUDE.md" ]] && grep -qi "python\|pip\|venv\|conda" "$dir/.claude/CLAUDE.md" 2>/dev/null; then
      has_python_section=true
    fi
    if [[ "$has_python_section" == "true" ]]; then
      score=$((score + 3))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Python project has Python-specific CLAUDE.md content" >&2
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] Python project but no Python guidance in .claude/CLAUDE.md" >&2
      _add_fix_stack "3|Python project but CLAUDE.md has no Python-specific context|cp $SCRIPT_DIR/templates/CLAUDE.md/python-api.md .claude/CLAUDE.md"
    fi
  fi

  if echo "$stacks" | grep -q "Docker"; then
    local has_docker_note=false
    if [[ -f "$dir/.claude/CLAUDE.md" ]] && grep -qi "docker\|compose\|container" "$dir/.claude/CLAUDE.md" 2>/dev/null; then
      has_docker_note=true
    fi
    if [[ "$has_docker_note" == "true" ]]; then
      score=$((score + 3))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Docker project mentions containers in CLAUDE.md" >&2
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] Docker detected but no container context in CLAUDE.md" >&2
      _add_fix_stack "3|Docker project but CLAUDE.md has no container context|Add docker/compose context to .claude/CLAUDE.md"
    fi
  fi

  if echo "$stacks" | grep -q "Node" && ! echo "$stacks" | grep -qE "Next.js|React"; then
    if [[ -f "$dir/.claude/CLAUDE.md" ]]; then
      score=$((score + 3))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Node project has project CLAUDE.md" >&2
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] Node project with no .claude/CLAUDE.md" >&2
      _add_fix_stack "3|Node project has no .claude/CLAUDE.md — Claude lacks project context|cp $SCRIPT_DIR/templates/CLAUDE.md/node-fullstack.md .claude/CLAUDE.md"
    fi
  fi

  echo "$score"
}
