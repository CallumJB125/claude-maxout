#!/usr/bin/env bash
# Layer 1: Claude Core audit — ~/.claude/ setup (max 30 pts)

_CORE_FIXES=()

audit_claude_core() {
  local score=0
  local claude_dir="$HOME/.claude"
  local claude_md="$claude_dir/CLAUDE.md"
  local settings="$claude_dir/settings.json"

  # CLAUDE.md existence (+5)
  if [[ -f "$claude_md" ]]; then
    score=$((score + 5))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] ~/.claude/CLAUDE.md exists"

    # Word count >200 (+5)
    local wc
    wc=$(wc -w < "$claude_md" 2>/dev/null || echo 0)
    if [[ "$wc" -gt 200 ]]; then
      score=$((score + 5))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] CLAUDE.md has $wc words (>200)"
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] CLAUDE.md only has $wc words — needs more content"
      _CORE_FIXES+=("5|Expand ~/.claude/CLAUDE.md — currently only $wc words (need >200)|cp $SCRIPT_DIR/templates/CLAUDE.md/base.md ~/.claude/CLAUDE.md")
    fi

    # Section count >=5 (+5)
    local sections
    sections=$(grep -c "^## " "$claude_md" 2>/dev/null || echo 0)
    if [[ "$sections" -ge 5 ]]; then
      score=$((score + 5))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] CLAUDE.md has $sections sections (>=5)"
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] CLAUDE.md only has $sections sections (need >=5)"
      _CORE_FIXES+=("5|Add more sections to ~/.claude/CLAUDE.md (have $sections, need >=5)|See templates/CLAUDE.md/base.md for structure")
    fi
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] ~/.claude/CLAUDE.md missing"
    _CORE_FIXES+=("15|Create a global ~/.claude/CLAUDE.md to give Claude persistent context|cp $SCRIPT_DIR/templates/CLAUDE.md/base.md ~/.claude/CLAUDE.md")
  fi

  # settings.json existence (+5)
  if [[ -f "$settings" ]]; then
    score=$((score + 5))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] ~/.claude/settings.json exists"

    # permissions block with >=3 rules (+5)
    local perm_count=0
    if command -v jq &>/dev/null; then
      perm_count=$(jq '[.permissions.allow // [] | length, .allowedTools // [] | length] | add // 0' "$settings" 2>/dev/null || echo 0)
    else
      perm_count=$(grep -c '"allow\|allowedTools' "$settings" 2>/dev/null || echo 0)
    fi
    if [[ "$perm_count" -ge 3 ]]; then
      score=$((score + 5))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] settings.json has $perm_count permission rules"
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] settings.json has $perm_count permission rules (need >=3)"
      _CORE_FIXES+=("5|Add permission rules to ~/.claude/settings.json to reduce prompts|cp $SCRIPT_DIR/templates/settings/settings-advanced.json ~/.claude/settings.json")
    fi

    # hooks block (+5)
    if grep -q '"hooks"' "$settings" 2>/dev/null; then
      score=$((score + 5))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] settings.json has hooks configured"
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] settings.json has no hooks configured"
      _CORE_FIXES+=("5|Add hooks to ~/.claude/settings.json for automation|See templates/settings/settings-advanced.json for hook examples")
    fi
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] ~/.claude/settings.json missing"
    _CORE_FIXES+=("10|Create ~/.claude/settings.json with permissions and hooks|cp $SCRIPT_DIR/templates/settings/settings-advanced.json ~/.claude/settings.json")
  fi

  echo "$score"
}

get_fixes_core() {
  printf '%s\n' "${_CORE_FIXES[@]:-}"
}
