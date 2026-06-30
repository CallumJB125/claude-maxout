#!/usr/bin/env bash
# Report engine — renders scored output or JSON

_bar() {
  local score="$1" max="$2" width=20
  local filled=$(( (score * width) / max ))
  local empty=$(( width - filled ))
  local bar=""
  local i
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done
  echo "$bar"
}

_grade() {
  local total="$1"
  if   [[ "$total" -ge 90 ]]; then echo "A"
  elif [[ "$total" -ge 75 ]]; then echo "B"
  elif [[ "$total" -ge 60 ]]; then echo "C"
  elif [[ "$total" -ge 45 ]]; then echo "D"
  else echo "F"
  fi
}

_all_fixes_sorted() {
  # Read all fix files and sort by points descending
  cat "$AUDIT_TMP"/fixes_*.txt 2>/dev/null | sort -t'|' -k1 -rn
}

render_report() {
  local s1="$1" s2="$2" s3="$3" s4="$4" s5="$5"
  local stacks="$6"
  local total=$(( s1 + s2 + s3 + s4 + s5 ))
  local grade
  grade=$(_grade "$total")

  if [[ "$JSON_OUTPUT" == "true" ]]; then
    local fixes_json="["
    local first=true
    while IFS='|' read -r pts desc cmd; do
      [[ -z "$pts" ]] && continue
      [[ "$first" == "true" ]] && first=false || fixes_json+=","
      fixes_json+="{\"pts\":$pts,\"description\":$(printf '%s' "$desc" | jq -Rs .),\"command\":$(printf '%s' "$cmd" | jq -Rs .)}"
    done < <(_all_fixes_sorted)
    fixes_json+="]"

    jq -n \
      --argjson total "$total" \
      --arg grade "$grade" \
      --arg stacks "$stacks" \
      --argjson l1 "$s1" --argjson l2 "$s2" --argjson l3 "$s3" \
      --argjson l4 "$s4" --argjson l5 "$s5" \
      --argjson fixes "$fixes_json" \
      '{score:$total,grade:$grade,stacks:$stacks,layers:{core:{score:$l1,max:30},project:{score:$l2,max:20},mcp:{score:$l3,max:20},stack:{score:$l4,max:15},env:{score:$l5,max:15}},fixes:$fixes}'
    return
  fi

  echo "SCORE: $total/100  $(_bar "$total" 100)  Grade: $grade"
  echo ""
  printf "%-28s %5s  %s\n" "Layer 1  Claude Core"    "$s1/30" "$(_bar "$s1" 30)"
  printf "%-28s %5s  %s\n" "Layer 2  Project Config"  "$s2/20" "$(_bar "$s2" 20)"
  printf "%-28s %5s  %s\n" "Layer 3  MCP Coverage"    "$s3/20" "$(_bar "$s3" 20)"
  printf "%-28s %5s  %s\n" "Layer 4  Stack Fit"       "$s4/15" "$(_bar "$s4" 15)"
  printf "%-28s %5s  %s\n" "Layer 5  Shell Ecosystem" "$s5/15" "$(_bar "$s5" 15)"
  echo ""

  local fixes_file
  fixes_file=$(_all_fixes_sorted)

  if [[ -n "$fixes_file" ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "TOP FIXES  (sorted by impact)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    local count=0
    local total_fixes=0
    total_fixes=$(echo "$fixes_file" | grep -c '|' || echo 0)
    while IFS='|' read -r pts desc cmd; do
      [[ -z "$pts" ]] && continue
      echo ""
      echo "[+$pts pts] $desc"
      echo "  → $cmd"
      count=$((count + 1))
      [[ "$VERBOSE" == "false" && "$count" -ge 5 ]] && break
    done <<< "$fixes_file"
    echo ""
    if [[ "$VERBOSE" == "false" && "$total_fixes" -gt 5 ]]; then
      echo "  ($total_fixes total fixes — run with --verbose to see all)"
    fi
  else
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "No gaps found — your ecosystem looks great!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  fi
  echo ""
  echo "Full catalog of MCP servers: docs/mcp-catalog.md"
  echo "Setup guides: docs/tmux-guide.md  docs/ghostty-guide.md"
  echo ""
}
