#!/usr/bin/env bash
# claude-maxout — audit your Claude Code ecosystem
# Usage: ./audit.sh [--json] [--verbose] [--fix]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Flags
JSON_OUTPUT=false
VERBOSE=false
FIX_MODE=false

for arg in "$@"; do
  case "$arg" in
    --json)    JSON_OUTPUT=true ;;
    --verbose) VERBOSE=true ;;
    --fix)     FIX_MODE=true ;;
  esac
done

export JSON_OUTPUT VERBOSE FIX_MODE SCRIPT_DIR

# Source all lib modules
source "$LIB_DIR/detect-stack.sh"
source "$LIB_DIR/audit-claude-core.sh"
source "$LIB_DIR/audit-project.sh"
source "$LIB_DIR/audit-mcp.sh"
source "$LIB_DIR/audit-stack.sh"
source "$LIB_DIR/audit-env.sh"
source "$LIB_DIR/report.sh"

# Run all audit layers
SCORE_CORE=0
SCORE_PROJECT=0
SCORE_MCP=0
SCORE_STACK=0
SCORE_ENV=0

FIXES_CORE=()
FIXES_PROJECT=()
FIXES_MCP=()
FIXES_STACK=()
FIXES_ENV=()

DETECTED_STACKS=""

if [[ "$JSON_OUTPUT" == "false" ]]; then
  echo ""
  echo "╔══════════════════════════════════════════╗"
  echo "║        claude-maxout audit v1.0          ║"
  echo "╚══════════════════════════════════════════╝"
  echo ""
fi

# Detect stack first (used by multiple layers)
DETECTED_STACKS=$(detect_stack)

if [[ "$JSON_OUTPUT" == "false" && -n "$DETECTED_STACKS" ]]; then
  echo "Stack detected: $DETECTED_STACKS"
  echo ""
fi

# Run layers
SCORE_CORE=$(audit_claude_core)
SCORE_PROJECT=$(audit_project)
SCORE_MCP=$(audit_mcp)
SCORE_STACK=$(audit_stack "$DETECTED_STACKS")
SCORE_ENV=$(audit_env)

# Collect fixes from each layer
mapfile -t FIXES_CORE  < <(get_fixes_core)
mapfile -t FIXES_PROJECT < <(get_fixes_project)
mapfile -t FIXES_MCP   < <(get_fixes_mcp)
mapfile -t FIXES_STACK < <(get_fixes_stack)
mapfile -t FIXES_ENV   < <(get_fixes_env)

ALL_FIXES=("${FIXES_CORE[@]:-}" "${FIXES_PROJECT[@]:-}" "${FIXES_MCP[@]:-}" "${FIXES_STACK[@]:-}" "${FIXES_ENV[@]:-}")

# Render report
render_report \
  "$SCORE_CORE" "$SCORE_PROJECT" "$SCORE_MCP" "$SCORE_STACK" "$SCORE_ENV" \
  "$DETECTED_STACKS" \
  "${ALL_FIXES[@]:-}"
