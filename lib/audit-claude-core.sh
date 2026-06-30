#!/usr/bin/env bash
# Layer 1: Claude Core audit — ~/.claude/ setup (max 30 pts)

_add_fix_core() {
  echo "$1" >> "$AUDIT_TMP/fixes_core.txt"
}

audit_claude_core() {
  local score=0
  local claude_dir="$HOME/.claude"
  local claude_md="$claude_dir/CLAUDE.md"
  local settings="$claude_dir/settings.json"

  if [[ -f "$claude_md" ]]; then
    score=$((score + 5))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] ~/.claude/CLAUDE.md exists" >&2

    local wc
    wc=$(wc -w < "$claude_md" 2>/dev/null | tr -d ' ' || echo 0)
    if [[ "$wc" -gt 200 ]]; then
      score=$((score + 5))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] CLAUDE.md has $wc words (>200)" >&2
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] CLAUDE.md only has $wc words — needs more content" >&2
      _add_fix_core "5|Expand ~/.claude/CLAUDE.md — currently only $wc words (need >200)|cp $SCRIPT_DIR/templates/CLAUDE.md/base.md ~/.claude/CLAUDE.md"
    fi

    local sections
    sections=$(grep -c "^## " "$claude_md" 2>/dev/null || echo 0)
    if [[ "$sections" -ge 5 ]]; then
      score=$((score + 5))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] CLAUDE.md has $sections sections (>=5)" >&2
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] CLAUDE.md only has $sections sections (need >=5)" >&2
      _add_fix_core "5|Add more sections to ~/.claude/CLAUDE.md (have $sections, need >=5)|See templates/CLAUDE.md/base.md for structure"
    fi
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] ~/.claude/CLAUDE.md missing" >&2
    _add_fix_core "15|Create a global ~/.claude/CLAUDE.md to give Claude persistent context|cp $SCRIPT_DIR/templates/CLAUDE.md/base.md ~/.claude/CLAUDE.md"
  fi

  if [[ -f "$settings" ]]; then
    score=$((score + 5))
    [[ "$VERBOSE" == "true" ]] && echo "  [PASS] ~/.claude/settings.json exists" >&2

    local perm_count=0
    if command -v jq &>/dev/null; then
      perm_count=$(jq '[.permissions.allow // [] | length, .allowedTools // [] | length] | add // 0' "$settings" 2>/dev/null || echo 0)
    else
      perm_count=$(grep -c '"allow\|allowedTools' "$settings" 2>/dev/null || echo 0)
    fi
    if [[ "$perm_count" -ge 3 ]]; then
      score=$((score + 5))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] settings.json has $perm_count permission rules" >&2
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] settings.json has $perm_count permission rules (need >=3)" >&2
      _add_fix_core "5|Add permission rules to ~/.claude/settings.json to reduce prompts|cp $SCRIPT_DIR/templates/settings/settings-advanced.json ~/.claude/settings.json"
    fi

    if grep -q '"hooks"' "$settings" 2>/dev/null; then
      score=$((score + 5))
      [[ "$VERBOSE" == "true" ]] && echo "  [PASS] settings.json has hooks configured" >&2
    else
      [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] settings.json has no hooks configured" >&2
      _add_fix_core "5|Add hooks to ~/.claude/settings.json for automation|See templates/settings/settings-advanced.json for hook examples"
    fi
  else
    [[ "$VERBOSE" == "true" ]] && echo "  [FAIL] ~/.claude/settings.json missing" >&2
    _add_fix_core "10|Create ~/.claude/settings.json with permissions and hooks|cp $SCRIPT_DIR/templates/settings/settings-advanced.json ~/.claude/settings.json"
  fi

  echo "$score"
}
