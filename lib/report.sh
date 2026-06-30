#!/usr/bin/env bash
# Report engine — renders scored output or JSON

_bar() {
  local score="$1"
  local max="$2"
  local width=20
  local filled=$(( (score * width) / max ))
  local empty=$(( width - filled ))
  printf '%0.s█' $(seq 1 $filled 2>/dev/null || true)
  printf '%0.s░' $(seq 1 $empty 2>/dev/null || true)
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

render_report() {
  local s1="$1" s2="$2" s3="$3" s4="$4" s5="$5"
  local stacks="$6"
  shift 6
  local fixes=("$@")

  local total=$(( s1 + s2 + s3 + s4 + s5 ))
  local grade
  grade=$(_grade "$total")

  if [[ "$JSON_OUTPUT" == "true" ]]; then
    # Sort fixes by impact (first field is pts)
    local fixes_json="["
    local first=true
    for fix in "${fixes[@]:-}"; do
      [[ -z "$fix" ]] && continue
      local pts desc cmd
      IFS='|' read -r pts desc cmd <<< "$fix"
      [[ "$first" == "true" ]] && first=false || fixes_json+=","
      fixes_json+="{\"pts\":$pts,\"description\":$(echo "$desc" | jq -Rs .),\"command\":$(echo "$cmd" | jq -Rs .)}"
    done
    fixes_json+="]"

    jq -n \
      --argjson total "$total" \
      --arg grade "$grade" \
      --arg stacks "$stacks" \
      --argjson layer1 "$s1" \
      --argjson layer2 "$s2" \
      --argjson layer3 "$s3" \
      --argjson layer4 "$s4" \
      --argjson layer5 "$s5" \
      --argjson fixes "$fixes_json" \
      '{score:$total,grade:$grade,stacks:$stacks,layers:{core:{score:$layer1,max:30},project:{score:$layer2,max:20},mcp:{score:$layer3,max:20},stack:{score:$layer4,max:15},env:{score:$layer5,max:15}},fixes:$fixes}'
    return
  fi

  echo "SCORE: $total/100  $(_bar $total 100)  Grade: $grade"
  echo ""
  printf "%-28s %5s  %s\n" "Layer 1  Claude Core"    "$s1/30"  "$(_bar $s1 30)"
  printf "%-28s %5s  %s\n" "Layer 2  Project Config"  "$s2/20"  "$(_bar $s2 20)"
  printf "%-28s %5s  %s\n" "Layer 3  MCP Coverage"    "$s3/20"  "$(_bar $s3 20)"
  printf "%-28s %5s  %s\n" "Layer 4  Stack Fit"       "$s4/15"  "$(_bar $s4 15)"
  printf "%-28s %5s  %s\n" "Layer 5  Shell Ecosystem" "$s5/15"  "$(_bar $s5 15)"
  echo ""

  # Sort and print top fixes
  local sorted_fixes=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && sorted_fixes+=("$line")
  done < <(printf '%s\n' "${fixes[@]:-}" | sort -t'|' -k1 -rn)

  if [[ "${#sorted_fixes[@]}" -gt 0 ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "TOP FIXES  (sorted by impact)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    local count=0
    for fix in "${sorted_fixes[@]}"; do
      [[ -z "$fix" ]] && continue
      local pts desc cmd
      IFS='|' read -r pts desc cmd <<< "$fix"
      echo ""
      echo "[+$pts pts] $desc"
      echo "  → $cmd"
      count=$((count + 1))
      [[ "$count" -ge 5 && "$VERBOSE" == "false" ]] && break
    done
    echo ""
    if [[ "$VERBOSE" == "false" && "${#sorted_fixes[@]}" -gt 5 ]]; then
      echo "  (${#sorted_fixes[@]} total fixes — run with --verbose to see all)"
    fi
  else
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "No fixes needed — your ecosystem looks great!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  fi
  echo ""
  echo "Full catalog of MCP servers: docs/mcp-catalog.md"
  echo "Setup guides: docs/tmux-guide.md  docs/ghostty-guide.md"
  echo ""
}
