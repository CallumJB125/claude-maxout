#!/usr/bin/env bash
# Layer 2: Project config audit — ./.claude/ per-project setup (max 20 pts)

_PROJECT_FIXES=()

audit_project() {
  local score=0
  local dir="${PROJECT_DIR:-$(pwd)}"
  local claude_dir="$dir/.claude"

  # .claude/ dir exists (+5)
  if [[ -d "$claude_dir" ]]; then
    score=$((score + 5))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] .claude/ directory exists"

    # .claude/CLAUDE.md (+5)
    if [[ -f "$claude_dir/CLAUDE.md" ]]; then
      score=$((score + 5))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] .claude/CLAUDE.md exists"
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] .claude/CLAUDE.md missing"
      _PROJECT_FIXES+=("5|Create a project-level .claude/CLAUDE.md for project-specific context|cp $SCRIPT_DIR/templates/CLAUDE.md/base.md .claude/CLAUDE.md")
    fi

    # .claude/settings.json (+5)
    if [[ -f "$claude_dir/settings.json" ]]; then
      score=$((score + 5))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] .claude/settings.json exists"
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] .claude/settings.json missing"
      _PROJECT_FIXES+=("5|Add .claude/settings.json for project-scoped permissions|cp $SCRIPT_DIR/templates/settings/settings-base.json .claude/settings.json")
    fi
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] No .claude/ directory in current project"
    _PROJECT_FIXES+=("15|Create .claude/ directory with CLAUDE.md and settings.json|mkdir -p .claude && cp $SCRIPT_DIR/templates/CLAUDE.md/base.md .claude/CLAUDE.md && cp $SCRIPT_DIR/templates/settings/settings-base.json .claude/settings.json")
  fi

  # .omc/ or workflow dir (+5)
  if [[ -d "$dir/.omc" || -d "$dir/.claude/workflows" ]]; then
    score=$((score + 5))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] Workflow/OMC directory present"
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] No .omc/ workflow directory"
    _PROJECT_FIXES+=("5|Set up oh-my-claudecode for advanced orchestration|npm install -g @anthropic/claude-code && claude /oh-my-claudecode:omc-setup")
  fi

  echo "$score"
}

get_fixes_project() {
  printf '%s\n' "${_PROJECT_FIXES[@]:-}"
}
