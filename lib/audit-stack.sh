#!/usr/bin/env bash
# Layer 4: Stack-specific gap analysis (max 15 pts)

_STACK_FIXES=()

audit_stack() {
  local stacks="${1:-}"
  local score=0
  local dir="${PROJECT_DIR:-$(pwd)}"

  if [[ -z "$stacks" ]]; then
    [[ "$VERBOSE" == "true" ]] && echo "  [INFO] No stack detected in current directory — run from a project root"
    echo "0"
    return
  fi

  [[ "$VERBOSE" == "true" ]] && echo "  [INFO] Auditing stack fit for: $stacks"

  local servers
  servers=$(_get_mcp_servers 2>/dev/null || echo "")

  # Next.js — needs context7
  if echo "$stacks" | grep -q "Next.js"; then
    if echo "$servers" | grep -qiE "context7|devdocs"; then
      score=$((score + 3))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Next.js + docs MCP configured"
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] Next.js detected but no docs MCP for real-time Next.js docs"
      _STACK_FIXES+=("3|You have Next.js but no docs MCP — Claude can't look up current Next.js APIs|Add context7: see templates/mcp/context7.json")
    fi
  fi

  # React — needs playwright for testing
  if echo "$stacks" | grep -q "React"; then
    if echo "$servers" | grep -qiE "playwright|browser"; then
      score=$((score + 3))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] React + browser testing MCP configured"
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] React detected but no browser automation MCP"
      _STACK_FIXES+=("3|React project with no browser MCP — Claude can't automate UI testing|Add Playwright MCP: see templates/mcp/playwright.json")
    fi
  fi

  # Python — check for project CLAUDE.md with python section
  if echo "$stacks" | grep -q "Python"; then
    local has_python_section=false
    if [[ -f "$dir/.claude/CLAUDE.md" ]] && grep -qi "python\|pip\|venv\|conda" "$dir/.claude/CLAUDE.md" 2>/dev/null; then
      has_python_section=true
    fi
    if [[ "$has_python_section" == "true" ]]; then
      score=$((score + 3))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Python project has Python-specific CLAUDE.md content"
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] Python project but no Python guidance in .claude/CLAUDE.md"
      _STACK_FIXES+=("3|Python project but CLAUDE.md has no Python-specific context|cp $SCRIPT_DIR/templates/CLAUDE.md/python-api.md .claude/CLAUDE.md")
    fi
  fi

  # Docker — check for docker compose awareness in CLAUDE.md
  if echo "$stacks" | grep -q "Docker"; then
    local has_docker_note=false
    if [[ -f "$dir/.claude/CLAUDE.md" ]] && grep -qi "docker\|compose\|container" "$dir/.claude/CLAUDE.md" 2>/dev/null; then
      has_docker_note=true
    fi
    if [[ "$has_docker_note" == "true" ]]; then
      score=$((score + 3))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Docker project mentions containers in CLAUDE.md"
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] Docker detected but no container context in CLAUDE.md"
      _STACK_FIXES+=("3|Docker project but CLAUDE.md has no container context — Claude may not know your service topology|Add docker/compose context to .claude/CLAUDE.md")
    fi
  fi

  # Node without any CLAUDE.md at all
  if echo "$stacks" | grep -q "Node" && ! echo "$stacks" | grep -qE "Next.js|React"; then
    if [[ -f "$dir/.claude/CLAUDE.md" ]]; then
      score=$((score + 3))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Node project has project CLAUDE.md"
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] Node project with no .claude/CLAUDE.md"
      _STACK_FIXES+=("3|Node project has no .claude/CLAUDE.md — Claude lacks project context|cp $SCRIPT_DIR/templates/CLAUDE.md/node-fullstack.md .claude/CLAUDE.md")
    fi
  fi

  echo "$score"
}

get_fixes_stack() {
  printf '%s\n' "${_STACK_FIXES[@]:-}"
}
