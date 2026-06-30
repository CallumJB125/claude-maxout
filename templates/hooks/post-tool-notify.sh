#!/usr/bin/env bash
# Post-tool hook — notify when Claude finishes a long operation
# Place in: ~/.claude/hooks/post-tool-notify.sh
# Wire up in settings.json:
#   "PostToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "~/.claude/hooks/post-tool-notify.sh"}]}]
#
# Sends a macOS notification when a Bash tool call completes.
# Useful for long builds/tests — you can alt-tab away and get pinged.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.command // ""' 2>/dev/null || echo "")

# Only notify for commands that typically take a while
if echo "$COMMAND" | grep -qE "npm (install|build|test|run)|pytest|go test|cargo build|make|docker build"; then
  # macOS notification
  if command -v osascript &>/dev/null; then
    SHORT_CMD=$(echo "$COMMAND" | cut -c1-60)
    osascript -e "display notification \"Finished: $SHORT_CMD\" with title \"Claude Code\" sound name \"Glass\"" 2>/dev/null || true
  fi
fi

exit 0
