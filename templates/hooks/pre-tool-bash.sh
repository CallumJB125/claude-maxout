#!/usr/bin/env bash
# Pre-tool hook for Bash commands
# Place in: ~/.claude/hooks/pre-tool-bash.sh
# Wire up in settings.json:
#   "PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "~/.claude/hooks/pre-tool-bash.sh"}]}]
#
# This hook receives the tool input as JSON on stdin.
# Exit 0 = allow. Exit non-zero = block (stderr shown to Claude).

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.command // ""' 2>/dev/null || echo "")

# Block accidental recursive deletions
if echo "$COMMAND" | grep -qE "^rm\s+-rf\s+/$|^rm\s+-rf\s+/usr|^rm\s+-rf\s+/etc"; then
  echo "BLOCKED: Dangerous recursive delete detected: $COMMAND" >&2
  exit 1
fi

# Warn on force push to main/master
if echo "$COMMAND" | grep -qE "git push.*--force.*(main|master)|git push.*(main|master).*--force"; then
  echo "BLOCKED: Force push to main/master requires explicit user confirmation." >&2
  exit 1
fi

exit 0
