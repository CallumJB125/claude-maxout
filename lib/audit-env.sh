#!/usr/bin/env bash
# Layer 5: Shell ecosystem audit (max 15 pts)

_ENV_FIXES=()

audit_env() {
  local score=0

  # tmux installed and active (+3)
  if command -v tmux &>/dev/null; then
    if [[ -n "${TMUX:-}" ]]; then
      score=$((score + 3))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] tmux installed and currently active"
    else
      score=$((score + 1))
      [[ "$VERBOSE" == "true" ]] && echo "  [WARN] tmux installed but not currently active (launch Claude inside tmux)"
      _ENV_FIXES+=("2|Start Claude Code inside a tmux session for persistent sessions across disconnects|tmux new -s claude && claude")
    fi
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] tmux not installed"
    _ENV_FIXES+=("3|Install tmux for persistent Claude Code sessions|brew install tmux  # then see docs/tmux-guide.md")
  fi

  # ~/.tmux.conf exists (+3)
  if [[ -f "$HOME/.tmux.conf" || -f "$HOME/.config/tmux/tmux.conf" ]]; then
    local conf_lines
    conf_lines=$(wc -l < "${HOME}/.tmux.conf" 2>/dev/null || wc -l < "${HOME}/.config/tmux/tmux.conf" 2>/dev/null || echo 0)
    if [[ "$conf_lines" -gt 1 ]]; then
      score=$((score + 3))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] tmux.conf exists with $conf_lines lines"
    else
      score=$((score + 1))
      [[ "$VERBOSE" == "true" ]] && echo "  [WARN] tmux.conf exists but nearly empty"
      _ENV_FIXES+=("2|Add useful tmux configuration|cp $SCRIPT_DIR/docs/tmux-guide.md /tmp/ && cat /tmp/tmux-guide.md")
    fi
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] No ~/.tmux.conf"
    _ENV_FIXES+=("3|Create a tmux config for better Claude Code sessions|See docs/tmux-guide.md for a minimal config")
  fi

  # Terminal is Ghostty (+3)
  local is_ghostty=false
  if [[ "${TERM_PROGRAM:-}" == "ghostty" ]] || [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]] || [[ -n "${GHOSTTY_BIN_DIR:-}" ]]; then
    is_ghostty=true
  fi
  if [[ "$is_ghostty" == "true" ]]; then
    score=$((score + 3))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Running in Ghostty terminal"
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [INFO] Not running in Ghostty (${TERM_PROGRAM:-unknown}) — optional but recommended"
    _ENV_FIXES+=("3|Use Ghostty terminal for best Claude Code experience (GPU rendering, shell integration)|https://ghostty.org — see docs/ghostty-guide.md")
  fi

  # git has useful aliases (+3)
  local has_git_alias=false
  if git config --get-regexp "alias\." 2>/dev/null | grep -qE "lg|log|st|co|br"; then
    has_git_alias=true
  fi
  if [[ "$has_git_alias" == "true" ]]; then
    score=$((score + 3))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] git has useful aliases configured"
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] git has no useful aliases"
    _ENV_FIXES+=("3|Add git aliases so Claude can use shorter commands|git config --global alias.lg 'log --oneline --graph --decorate'")
  fi

  # Claude Code version check (+3)
  if command -v claude &>/dev/null; then
    score=$((score + 3))
    local claude_version
    claude_version=$(claude --version 2>/dev/null | head -1 || echo "unknown")
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Claude Code installed: $claude_version"
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] Claude Code (claude CLI) not found in PATH"
    _ENV_FIXES+=("3|Ensure Claude Code CLI is in your PATH|npm install -g @anthropic-ai/claude-code")
  fi

  echo "$score"
}

get_fixes_env() {
  printf '%s\n' "${_ENV_FIXES[@]:-}"
}
