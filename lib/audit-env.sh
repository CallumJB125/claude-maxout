#!/usr/bin/env bash
# Layer 5: Shell ecosystem audit (max 15 pts)

_add_fix_env() {
  echo "$1" >> "$AUDIT_TMP/fixes_env.txt"
}

audit_env() {
  local score=0

  if command -v tmux &>/dev/null; then
    if [[ -n "${TMUX:-}" ]]; then
      score=$((score + 3))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] tmux installed and currently active" >&2
    else
      score=$((score + 1))
      [[ "$VERBOSE" == "true" ]] && echo "  [WARN] tmux installed but not currently active" >&2
      _add_fix_env "2|Start Claude Code inside a tmux session for persistent sessions|tmux new -s claude && claude"
    fi
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] tmux not installed" >&2
    _add_fix_env "3|Install tmux for persistent Claude Code sessions|brew install tmux  # then see docs/tmux-guide.md"
  fi

  if [[ -f "$HOME/.tmux.conf" || -f "$HOME/.config/tmux/tmux.conf" ]]; then
    local conf_lines
    conf_lines=$(wc -l < "${HOME}/.tmux.conf" 2>/dev/null | tr -d ' ' || wc -l < "${HOME}/.config/tmux/tmux.conf" 2>/dev/null | tr -d ' ' || echo 0)
    if [[ "$conf_lines" -gt 1 ]]; then
      score=$((score + 3))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] tmux.conf exists with $conf_lines lines" >&2
    else
      score=$((score + 1))
      [[ "$VERBOSE" == "true" ]] && echo "  [WARN] tmux.conf exists but nearly empty" >&2
      _add_fix_env "2|Add useful tmux configuration|See docs/tmux-guide.md for a minimal config"
    fi
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] No ~/.tmux.conf" >&2
    _add_fix_env "3|Create a tmux config for better Claude Code sessions|See docs/tmux-guide.md for a minimal config"
  fi

  local is_ghostty=false
  if [[ "${TERM_PROGRAM:-}" == "ghostty" ]] || [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]] || [[ -n "${GHOSTTY_BIN_DIR:-}" ]]; then
    is_ghostty=true
  fi
  if [[ "$is_ghostty" == "true" ]]; then
    score=$((score + 3))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Running in Ghostty terminal" >&2
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [INFO] Not running in Ghostty (${TERM_PROGRAM:-unknown}) — optional but recommended" >&2
    _add_fix_env "3|Use Ghostty terminal for best Claude Code experience|https://ghostty.org — see docs/ghostty-guide.md"
  fi

  if git config --get-regexp "alias\." 2>/dev/null | grep -qE "lg|log|st|co|br"; then
    score=$((score + 3))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] git has useful aliases configured" >&2
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] git has no useful aliases" >&2
    _add_fix_env "3|Add git aliases so Claude can use shorter commands|git config --global alias.lg 'log --oneline --graph --decorate'"
  fi

  if command -v claude &>/dev/null; then
    score=$((score + 3))
    local claude_version
    claude_version=$(claude --version 2>/dev/null | head -1 || echo "unknown")
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Claude Code installed: $claude_version" >&2
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] Claude Code (claude CLI) not found in PATH" >&2
    _add_fix_env "3|Ensure Claude Code CLI is in your PATH|npm install -g @anthropic-ai/claude-code"
  fi

  echo "$score"
}
