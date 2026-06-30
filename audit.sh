#!/usr/bin/env bash
# claude-maxout — audit your Claude Code ecosystem
# Usage: ./audit.sh [--json] [--verbose] [--fix]

set -euo pipefail

# When piped via bash <(curl ...), BASH_SOURCE[0] is /dev/stdin — clone the repo instead
if [[ "${BASH_SOURCE[0]}" == "/dev/stdin" || "${BASH_SOURCE[0]}" == "bash" ]]; then
  SCRIPT_DIR=$(mktemp -d)
  git clone --depth 1 https://github.com/CallumJB125/claude-maxout.git "$SCRIPT_DIR" &>/dev/null
  trap 'rm -rf "$SCRIPT_DIR"' EXIT
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
LIB_DIR="$SCRIPT_DIR/lib"

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

# Temp dir for cross-subshell communication (fixes arrays)
AUDIT_TMP=$(mktemp -d)
export AUDIT_TMP
trap 'rm -rf "$AUDIT_TMP"' EXIT

# shellcheck source=lib/detect-stack.sh
source "$LIB_DIR/detect-stack.sh"
# shellcheck source=lib/audit-claude-core.sh
source "$LIB_DIR/audit-claude-core.sh"
# shellcheck source=lib/audit-project.sh
source "$LIB_DIR/audit-project.sh"
# shellcheck source=lib/audit-mcp.sh
source "$LIB_DIR/audit-mcp.sh"
# shellcheck source=lib/audit-stack.sh
source "$LIB_DIR/audit-stack.sh"
# shellcheck source=lib/audit-env.sh
source "$LIB_DIR/audit-env.sh"
# shellcheck source=lib/report.sh
source "$LIB_DIR/report.sh"

if [[ "$JSON_OUTPUT" == "false" ]]; then
  echo ""
  echo "╔══════════════════════════════════════════╗"
  echo "║        claude-maxout audit v1.0          ║"
  echo "╚══════════════════════════════════════════╝"
  echo ""
fi

DETECTED_STACKS=$(detect_stack)

if [[ "$JSON_OUTPUT" == "false" && -n "$DETECTED_STACKS" ]]; then
  echo "Stack detected: $DETECTED_STACKS"
  echo ""
fi

# Run layers — each writes its score to a tmp file and fixes to fixes_<layer>.txt
SCORE_CORE=$(audit_claude_core)
SCORE_PROJECT=$(audit_project)
SCORE_MCP=$(audit_mcp)
SCORE_STACK=$(audit_stack "$DETECTED_STACKS")
SCORE_ENV=$(audit_env)

render_report \
  "$SCORE_CORE" "$SCORE_PROJECT" "$SCORE_MCP" "$SCORE_STACK" "$SCORE_ENV" \
  "$DETECTED_STACKS"
